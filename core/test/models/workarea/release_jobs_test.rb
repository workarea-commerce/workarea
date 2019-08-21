require 'test_helper'

module Workarea
  class ReleaseJobsTest < TestCase
    setup :setup_sidekiq
    teardown :teardown_sidekiq

    def setup_sidekiq
      Sidekiq::Testing.disable!

      @scheduled_set = Sidekiq::ScheduledSet.new
      @scheduled_set.clear
    end

    def teardown_sidekiq
      Sidekiq::Testing.inline!
    end

    def test_save_updates_the_publish_job
      release = create_release
      release.publish_at = Time.current + 1.month

      release.save
      release.reload

      assert(release.publish_job_id.present?)
    end

    def test_save_does_not_save_the_publish_job_id_when_not_changing_publish_date
      release = create_release
      assert(release.publish_job_id.blank?)
      assert_equal(0, @scheduled_set.size)
    end

    def test_removing_publish_at_removes_job
      release = create_release(publish_at: 1.week.from_now)
      assert(release.publish_job_id.present?)
      assert_equal(1, @scheduled_set.size)

      release.update_attributes!(publish_at: nil)
      release.reload
      assert(release.publish_job_id.blank?)
      assert_equal(0, @scheduled_set.size)
    end

    def test_destroy_deletes_the_publish_job
      release = create_release(publish_job_id: '1234')
      release.destroy
      assert_equal(0, @scheduled_set.size)
    end
  end
end
