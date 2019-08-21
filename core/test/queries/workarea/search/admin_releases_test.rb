require 'test_helper'

module Workarea
  module Search
    class AdminReleasesTest < IntegrationTest
      setup :create_releases

      def create_releases
        @scheduled = create_release(name: 'Scheduled Release', publish_at: 1.week.from_now)
        @unscheduled = create_release(name: 'Unscheduled Release', created_at: Time.zone.local(2016, 6, 6))
        @published = create_release(name: 'Published Release', published_at: 1.week.ago)
        @undone = create_release(name: 'Undone Release', published_at: 2.week.ago, undone_at: 1.day.ago)
        @scheduled_undo_1 = create_release(name: 'Scheduled Undo Release 1', published_at: 5.week.ago, undo_at: 1.day.from_now)
        @scheduled_undo_2 = create_release(name: 'Scheduled Undo Release 2', published_at: 4.week.ago, undo_at: 3.day.from_now)
        @scheduled_undo_3 = create_release(name: 'Scheduled Undo Release 3', published_at: 3.week.ago, undo_at: 2.day.from_now)
      end

      def test_filter
        search = AdminReleases.new(publishing: 'scheduled')
        assert_equal(1, search.total)
        assert_includes(search.results, @scheduled)

        search = AdminReleases.new(publishing: 'unscheduled')
        assert_equal(1, search.total)
        assert_includes(search.results, @unscheduled)

        search = AdminReleases.new(publishing: 'published')
        assert_equal(5, search.total)
        assert_includes(search.results, @published)
        assert_includes(search.results, @undone)
        assert_includes(search.results, @scheduled_undo_1)
        assert_includes(search.results, @scheduled_undo_2)
        assert_includes(search.results, @scheduled_undo_3)

        search = AdminReleases.new(publishing: 'undone')
        assert_equal(1, search.total)
        assert_includes(search.results, @undone)

        search = AdminReleases.new(publishing: 'scheduled_undo')
        assert_equal(3, search.total)
        assert_includes(search.results, @scheduled_undo_1)
        assert_includes(search.results, @scheduled_undo_2)
        assert_includes(search.results, @scheduled_undo_3)
      end

      def test_sort
        search = AdminReleases.new(sort: 'published_date')
        assert_equal(@published, search.results.first)
        assert_equal(@undone, search.results.second)
        assert_equal(@scheduled_undo_3, search.results.third)

        search = AdminReleases.new(sort: 'undo_date')
        assert_equal(@scheduled_undo_1, search.results.first)
        assert_equal(@scheduled_undo_3, search.results.second)
        assert_equal(@scheduled_undo_2, search.results.third)
      end

      def test_filter_by_date
        search = AdminReleases.new(
          created_at_greater_than: Time.zone.local(2016, 6, 6),
          created_at_less_than: Time.zone.local(2016, 6, 6)
        )
        assert_equal(1, search.total)
      end
    end
  end
end
