require 'test_helper'

module Workarea
  module Admin
    class ReleaseCalendarViewModelTest < TestCase
      setup :set_release

      def set_release
        @release = create_release
      end

      def test_days_returns_a_month_hash_containing_published_releases_by_day
        @release.published_at = Time.current
        @release.save!

        view_model = ReleaseCalendarViewModel.new(@release)
        day = view_model.days[Time.current.strftime('%Y-%m-%d').to_s]

        assert_equal(1, day.length)
        assert_equal(@release.id, day.first.id)
      end

      def test_days_returns_a_month_hash_containing_scheduled_releases_by_day
        @release.publish_at = Time.current + 1.day
        @release.save!

        view_model = ReleaseCalendarViewModel.new(@release)
        day = view_model.days[(Time.current + 1.day).strftime('%Y-%m-%d').to_s]

        assert_equal(1, day.length)
        assert_equal(@release.id, day.first.id)
      end

      def test_days_sorts_results
        travel_to Time.zone.local(2019, 6, 24, 9, 35)

        @release.update_attributes!(name: 'Third', publish_at: 3.hours.from_now)
        create_release(name: 'First', published_at: 1.hour.ago)
        create_release(name: 'Second', publish_at: 2.hours.from_now)

        view_model = ReleaseCalendarViewModel.wrap(@release)
        day = view_model.days[(@release.publish_at).strftime('%Y-%m-%d').to_s]

        assert_equal(3, day.length)
        assert_equal('First', day.first.name)
        assert_equal('Second', day.second.name)
        assert_equal('Third', day.third.name)
      end

      def test_prev_week
        view_model = ReleaseCalendarViewModel.new(@release)
        assert_equal(Time.zone.today - 1.week, view_model.prev_week)
      end

      def test_next_week
        view_model = ReleaseCalendarViewModel.new(@release)
        assert_equal(Time.zone.today + 1.week, view_model.next_week)
      end

      def test_weekdays
        view_model = ReleaseCalendarViewModel.new(@release)

        assert_equal(7, view_model.weekdays.length)
        assert_equal('Sun', view_model.weekdays.first)
        assert_equal('Sat', view_model.weekdays.last)
      end

      def test_start_date_returns_today_s_date_if_no_start_date_supplied
        view_model = ReleaseCalendarViewModel.new(@release)
        assert_equal(Time.zone.today, view_model.start_date)
      end

      def test_start_date_returns_the_supplied_start_date
        options = { start_date: Time.zone.today + 1.month }
        view_model = ReleaseCalendarViewModel.new(@release, options)

        assert_equal(Time.zone.today + 1.month, view_model.start_date)
      end

      def test_unscheduled
        view_model = ReleaseCalendarViewModel.new(@release)

        assert_equal(1, view_model.unscheduled.length)
        assert_equal('Content Release', view_model.unscheduled.first.name)
      end
    end
  end
end
