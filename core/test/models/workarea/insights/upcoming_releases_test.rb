require 'test_helper'

module Workarea
  module Insights
    class UpcomingReleasesTest < TestCase
      def test_results
        one = create_release(publish_at: 1.week.from_now)
        two = create_release(publish_at: 2.weeks.from_now)
        three = create_release(publish_at: nil)

        UpcomingReleases.generate_monthly!
        assert_equal(1, UpcomingReleases.count)

        upcoming_releases = UpcomingReleases.first
        assert_equal(2, upcoming_releases.results.size)
        assert_equal(one.id, upcoming_releases.results.first['release_id'])
        assert_equal(two.id, upcoming_releases.results.second['release_id'])
      end
    end
  end
end
