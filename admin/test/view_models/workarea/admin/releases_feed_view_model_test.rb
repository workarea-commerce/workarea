require 'test_helper'

module Workarea
  module Admin
    class ReleasesFeedViewModelTest < TestCase
      def test_calendar
        foo_publish_at = 1.hour.from_now
        foo_undo_at = 2.hours.from_now
        foo_release = create_release(
          name: 'Foo',
          publish_at: foo_publish_at,
          undo_at: foo_undo_at
        )

        bar_publish_at = 1.week.from_now
        bar_undo_at = 2.weeks.from_now
        bar_release = create_release(
          name: 'Bar',
          publish_at: bar_publish_at,
          undo_at: bar_undo_at
        )

        vm = ReleasesFeedViewModel.wrap(nil)
        feed = vm.calendar

        assert_equal(2, feed.events.length)

        assert_equal('Foo', feed.events.first.summary)
        assert_equal('Bar', feed.events.second.summary)

        assert_equal(foo_publish_at.to_s, feed.events.first.dtstart.to_s)
        assert_equal(foo_undo_at.to_s, feed.events.first.dtend.to_s)

        assert_equal(bar_publish_at.to_date.to_s, feed.events.second.dtstart.to_s)
        assert_equal(bar_undo_at.to_date.to_s, feed.events.second.dtend.to_s)
      end
    end
  end
end
