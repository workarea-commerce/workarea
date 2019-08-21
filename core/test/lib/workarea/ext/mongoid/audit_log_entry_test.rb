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
    end
  end
end
