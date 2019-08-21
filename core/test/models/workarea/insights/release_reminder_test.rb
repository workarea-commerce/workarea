require 'test_helper'

module Workarea
  module Insights
    class ReleaseReminderTest < TestCase
      def test_results
        travel_to Time.zone.local(2019, 1, 6, 1)
        one = create_release(publish_at: Time.zone.local(2019, 1, 6, 2))

        travel_to Time.zone.local(2019, 1, 7, 1)
        two = create_release(publish_at: Time.zone.local(2019, 1, 7, 2))
        three = create_release(publish_at: Time.zone.local(2019, 1, 8, 2))
        four = create_release(publish_at: Time.zone.local(2019, 1, 9, 2))
        five = create_release(publish_at: nil)

        ReleaseReminder.generate_daily!
        assert_equal(1, ReleaseReminder.count)

        release_reminder = ReleaseReminder.first
        assert_equal(1, release_reminder.results.size)
        assert_equal(three.id, release_reminder.results.first['release_id'])
      end
    end
  end
end
