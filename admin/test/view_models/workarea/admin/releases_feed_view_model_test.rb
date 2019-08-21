require 'test_helper'

module Workarea
  module Admin
    class ReleasesFeedViewModelTest < TestCase
      def test_calendar
        foo_release = create_release(name: 'Foo', publish_at: 1.hour.from_now)
        bar_release = create_release(name: 'Bar', publish_at: 1.week.from_now)

        view_model = ReleasesFeedViewModel.new
        feed = view_model.calendar

        assert_equal(2, feed.events.length)

        assert_equal('Foo', feed.events.first.summary)
        assert_equal('Bar', feed.events.second.summary)

        assert_equal(foo_release.publish_at.to_s, feed.events.first.dtstart.to_s)
        assert(feed.events.first.dtend.present?)

        assert_equal(bar_release.publish_at.to_s, feed.events.second.dtstart.to_s)
        assert(feed.events.second.dtend.present?)
      end
    end
  end
end
