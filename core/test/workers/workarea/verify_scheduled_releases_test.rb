require 'test_helper'

module Workarea
  class VerifyScheduledReleasesTest < TestCase
    setup :set_sidekiq
    teardown :reset_sidekiq

    def set_sidekiq
      Sidekiq::Testing.disable!

      @scheduled_set = Sidekiq::ScheduledSet.new
      @scheduled_set.clear
    end

    def reset_sidekiq
      Sidekiq::Testing.inline!
    end

    def test_rescheduling_publish
      release = create_release(publish_at: Time.current + 1.hour)

      assert(release.publish_job_id.present?)
      original_job_id = release.publish_job_id
      @scheduled_set.clear

      VerifyScheduledReleases.new.perform
      release.reload

      refute_equal(original_job_id, release.publish_job_id)
      assert_equal(1, @scheduled_set.size)
    end

    def test_skipping_publish_dates_in_the_past
      release = create_release
      release.update_attribute(:publish_at, Time.current - 1.hour)
      release.update_attribute(:publish_job_id, '123')

      VerifyScheduledReleases.new.perform
      release.reload

      assert_equal('123', release.publish_job_id)
      assert_equal(0, @scheduled_set.size)
    end
  end
end
