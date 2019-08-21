require 'test_helper'

module Workarea
  class SchedulerTest < TestCase
    class MockWorker
      include Sidekiq::Worker

      def perform(*)
      end
    end

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

    def test_adding_and_removing_a_job
      scheduler = Scheduler.new(
        worker: MockWorker,
        at: 1.week.from_now,
        args: [1, 2, 3]
      )

      scheduler.perform
      first_job_id = scheduler.job_id
      assert_equal(1, @scheduled_set.size)

      scheduler.perform
      second_job_id = scheduler.job_id
      assert_equal(1, @scheduled_set.size)

      assert(first_job_id.present?)
      assert(second_job_id.present?)
      refute_equal(first_job_id, second_job_id)
    end
  end
end
