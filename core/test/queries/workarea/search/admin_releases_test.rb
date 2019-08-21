require 'test_helper'

module Workarea
  module Search
    class AdminReleasesTest < IntegrationTest
      setup :create_releases

      def create_releases
        @scheduled = create_release(name: 'Scheduled Release', publish_at: 1.week.from_now)
        @unscheduled = create_release(name: 'Unscheduled Release', created_at: Time.zone.local(2016, 6, 6))
        @published = create_release(name: 'Published Release', published_at: 1.week.ago)
      end

      def test_filter
        search = AdminReleases.new(publishing: 'scheduled')
        assert_equal(1, search.total)
        assert_includes(search.results, @scheduled)

        search = AdminReleases.new(publishing: 'unscheduled')
        assert_equal(1, search.total)
        assert_includes(search.results, @unscheduled)

        search = AdminReleases.new(publishing: 'published')
        assert_equal(1, search.total)
        assert_includes(search.results, @published)
      end

      def test_sort
        search = AdminReleases.new(sort: 'published_date')
        assert_equal(@published, search.results.first)
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
