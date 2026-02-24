require 'test_helper'

module Mongoid
  module AuditLog
    class EntryTest < Workarea::TestCase
      def test_release_is_recorded_if_there_is_a_release_present_when_saving
        product = create_product(name: 'Foo')
        release = create_release
        Mongoid::AuditLog.record do
          release.as_current do
            product.update_attributes!(name: 'Bar')
          end
        end

        entry = Mongoid::AuditLog::Entry.desc(:created_at).first
        assert_equal(release, entry.release)

        order = create_order
        Mongoid::AuditLog.record do
          release.as_current do
            order.update_attributes!(email: 'bcrouse@weblinc.com')
          end
        end

        entry = Mongoid::AuditLog::Entry.desc(:created_at).first
        assert(entry.release.blank?)
      end

      def test_insert_persists_all_entries_for_root_documents_in_a_release
        product = create_product(name: 'Foo')

        create_release.as_current do
          2.times do
            Entry.create!(
              audited_id: product.id,
              audited_type: product.class,
              tracked_changes: { 'foo' => 'bar' }
            )
          end
        end

        assert_equal(2, Entry.count)
      end

      def test_orphaned_navigation_taxons_cannot_be_restored
        AuditLog.record do
          product = create_product.tap(&:destroy!)
          parent = create_taxon(name: 'Parent').tap(&:save!)
          child = parent.children.create!(name: 'Child')

          parent.destroy!
          child.destroy!

          product_entry = product.audit_log_entries.newest.first
          parent_entry = parent.audit_log_entries.newest.first
          child_entry = child.audit_log_entries.newest.first

          refute(product_entry.send(:orphaned?))
          assert(product_entry.restorable?)
          refute(parent_entry.send(:orphaned?))
          assert(parent_entry.restorable?)
          assert(child_entry.send(:orphaned?))
          refute(child_entry.restorable?)
        end
      end

      # WA-NEW-010: The :action field was re-declared as String (was Symbol) to
      # eliminate the BSON Symbol deprecation warning.  The #action reader wraps
      # the stored string with to_sym so that all callers continue to receive a
      # Ruby Symbol, and the gem's own create?/update?/destroy? predicates
      # (which compare `action == :create` etc.) continue to work.
      def test_action_returns_symbol_after_field_type_change
        # Use the normal audit-log path so the full recording pipeline is
        # exercised: AuditLog.record → after_create callback → Entry persisted.
        Mongoid::AuditLog.record { create_product }

        entry = Mongoid::AuditLog::Entry.desc(:created_at).first

        # #action must return a Symbol even though the field is stored as String.
        assert_instance_of Symbol, entry.action
        assert_equal :create, entry.action

        # Gem predicates rely on Symbol comparison; they must still work.
        assert entry.create?,  'create? should be true for a :create entry'
        refute entry.update?,  'update? should be false for a :create entry'
        refute entry.destroy?, 'destroy? should be false for a :create entry'
      end

      # WA-NEW-010: Backwards-compatibility with existing documents whose
      # :action field was written as a BSON Symbol (wire type 0x0E) before the
      # field type was changed to String.  The BSON driver decodes type 0x0E as
      # a Ruby Symbol; Mongoid's String demongoizer converts that to a String
      # via to_s; our #action reader then calls to_sym, recovering the Symbol.
      def test_action_reads_legacy_bson_symbol_documents_as_symbol
        # Insert a raw document simulating the old on-disk format where
        # :action was stored as BSON Symbol (0x0E) rather than String (0x02).
        result = Entry.collection.insert_one(
          action:          BSON::Symbol::Raw.new('create'),
          tracked_changes: {},
          model_attributes: {},
          document_path:   [],
          restored:        false,
          created_at:      Time.current
        )

        # Load it through the full Mongoid stack.
        entry = Entry.find(result.inserted_id)

        # The public contract must be preserved: callers always get a Symbol.
        assert_instance_of Symbol, entry.action
        assert_equal :create, entry.action
      end

      # WA-NEW-010: Query round-trip — new entries are stored with :action as
      # String, but callers that query with a Symbol literal must still find
      # them.  Mongoid casts the query value through the String field type
      # (Symbol#to_s → "create"), so Entry.where(action: :create) matches
      # documents that store the string "create".
      def test_where_action_query_with_symbol_matches_string_stored_entries
        # Create one entry for each action type.  Entry.create! goes through
        # Mongoid's String mongoizer, which stores :create as "create" on disk.
        Entry.create!(action: :create,  tracked_changes: {})
        Entry.create!(action: :update,  tracked_changes: {})
        Entry.create!(action: :destroy, tracked_changes: {})

        creates  = Entry.where(action: :create)
        updates  = Entry.where(action: :update)
        destroys = Entry.where(action: :destroy)

        assert_equal 1, creates.count,  'Expected exactly 1 :create entry'
        assert_equal 1, updates.count,  'Expected exactly 1 :update entry'
        assert_equal 1, destroys.count, 'Expected exactly 1 :destroy entry'

        assert_equal :create,  creates.first.action
        assert_equal :update,  updates.first.action
        assert_equal :destroy, destroys.first.action
      end
    end
  end
end
