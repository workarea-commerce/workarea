require 'test_helper'

module Workarea
  class IndexReleaseSchedulePreviewsTest < TestCase
    def test_affected_releases
      release = create_release
      results = IndexReleaseSchedulePreviews.new(release: release).affected_releases
      assert_equal([release], results)

      a = create_release(publish_at: 1.week.from_now)
      b = create_release(publish_at: 2.weeks.from_now)
      c = create_release(publish_at: 4.weeks.from_now)
      assert_equal([a, b, c], IndexReleaseSchedulePreviews.new.affected_releases)

      results = IndexReleaseSchedulePreviews
        .new(starts_at: 3.days.from_now, ends_at: 17.days.from_now)
        .affected_releases

      assert_equal([a, b], results)

      results = IndexReleaseSchedulePreviews
        .new(release: release, starts_at: 3.days.from_now, ends_at: 10.days.from_now)
        .affected_releases

      assert_equal([a, release], results)
    end
  end
end
