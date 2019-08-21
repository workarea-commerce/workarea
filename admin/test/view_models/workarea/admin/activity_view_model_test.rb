require 'test_helper'

module Workarea
  module Admin
    class ActivityViewModelTest < TestCase
      include SearchIndexing

      def test_filters_by_modifier
        admin_one = create_user
        admin_two = create_user
        admin_three = create_user

        one = create_audit_log_entry(modifier: admin_one)
        two = create_audit_log_entry(modifier: admin_one)
        three = create_audit_log_entry(modifier: admin_two)
        create_audit_log_entry(modifier: admin_three)

        view_model = ActivityViewModel.new(
          nil,
          admin: [admin_one.id, admin_two.id]
        )

        assert_equal(3, view_model.entries.count)
        assert_includes(view_model.entries, one)
        assert_includes(view_model.entries, two)
        assert_includes(view_model.entries, three)
      end

      def test_filters_by_audited_type
        audited_one = create_page
        audited_two = create_category
        audited_three = create_product

        one = create_audit_log_entry(audited: audited_one)
        two = create_audit_log_entry(audited: audited_one)
        three = create_audit_log_entry(audited: audited_two)
        create_audit_log_entry(audited: audited_three)

        view_model = ActivityViewModel.new(
          nil,
          type: [one.audited_type, three.audited_type]
        )

        assert_equal(3, view_model.entries.count)
        assert_includes(view_model.entries, one)
        assert_includes(view_model.entries, two)
        assert_includes(view_model.entries, three)
      end

      def test_filters_by_audited_id
        audited_one = create_page
        audited_two = create_category
        audited_three = create_product

        one = create_audit_log_entry(audited: audited_one)
        two = create_audit_log_entry(audited: audited_one)
        three = create_audit_log_entry(audited: audited_two)
        create_audit_log_entry(audited: audited_three)

        view_model = ActivityViewModel.new(
          nil,
          id: [one.audited_id, three.audited_id]
        )

        assert_equal(3, view_model.entries.count)
        assert_includes(view_model.entries, one)
        assert_includes(view_model.entries, two)
        assert_includes(view_model.entries, three)
      end

      def test_filters_by_document_path
        ids = Array.new(4) { BSON::ObjectId.new }

        Mongoid::AuditLog::Entry
          .new(
            modifier_id: 'foo',
            audited_id: ids.first,
            document_path: [{ 'id' => ids.second }, { 'id' => ids.fourth }]
          )
          .save(validate: false)

        Mongoid::AuditLog::Entry
          .new(
            modifier_id: 'bar',
            audited_id: ids.third
          )
          .save(validate: false)

        view_model = ActivityViewModel.new(nil, id: ids.second.to_s)
        assert_equal(1, view_model.entries.count)
        assert_equal('foo', view_model.entries.first.modifier_id)
      end

      def test_filters_by_creation_date
        day_one = [
          create_audit_log_entry(created_at: 2.3.days.ago),
          create_audit_log_entry(created_at: 2.2.days.ago),
          create_audit_log_entry(created_at: 2.1.days.ago)
        ]
        day_two = [
          create_audit_log_entry(created_at: 1.3.days.ago),
          create_audit_log_entry(created_at: 1.2.days.ago),
          create_audit_log_entry(created_at: 1.1.days.ago)
        ]

        view_model = ActivityViewModel.new(nil, created_at_greater_than: 1.5.days.ago)
        assert_equal(day_two.reverse, view_model.entries.to_a)

        view_model = ActivityViewModel.new(nil, created_at_less_than: 1.5.days.ago)
        assert_equal(day_one.reverse, view_model.entries.to_a)
      end

      def test_does_not_include_entries_without_modifiers
        no_modifier = Mongoid::AuditLog::Entry.new
        no_modifier.save(validate: false)

        view_model = ActivityViewModel.new
        assert_equal(0, view_model.entries.count)
      end

      def test_groups_audit_log_entries_by_days
        travel_to Time.new(2017, 5, 22)
        day_one = [
          create_audit_log_entry,
          create_audit_log_entry,
          create_audit_log_entry
        ]

        travel_to Time.new(2017, 5, 23)
        day_two = [
          create_audit_log_entry,
          create_audit_log_entry,
          create_audit_log_entry
        ]

        travel_to Time.new(2017, 5, 24)
        view_model = ActivityViewModel.new

        assert_equal(2, view_model.days.size)
        results = view_model.days.to_a
        assert_equal(day_two.reverse, results.first.last)
        assert_equal(day_one.reverse, results.second.last)
      end

      def test_hide_first_header
        travel_to Time.new(2017, 5, 22)
        3.times { create_audit_log_entry }

        travel_to Time.new(2017, 5, 23)
        3.times { create_audit_log_entry }

        travel_to Time.new(2017, 5, 24)
        view_model = ActivityViewModel.new(nil, per_page: 1)
        refute(view_model.hide_first_header?)

        view_model = ActivityViewModel.new(nil, page: 2, per_page: 1)
        assert(view_model.hide_first_header?)

        view_model = ActivityViewModel.new(nil, page: 3, per_page: 1)
        assert(view_model.hide_first_header?)

        view_model = ActivityViewModel.new(nil, page: 4, per_page: 1)
        refute(view_model.hide_first_header?)

        view_model = ActivityViewModel.new(nil, page: 5, per_page: 1)
        assert(view_model.hide_first_header?)

        view_model = ActivityViewModel.new(nil, page: 5, per_page: 1)
        assert(view_model.hide_first_header?)
      end
    end
  end
end
