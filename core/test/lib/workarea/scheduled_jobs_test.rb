require 'test_helper'

module Workarea
  class ScheduledJobsTest < TestCase
    def test_remove_dead_jobs_after_initialize
      Sidekiq.logger.log_at(:error) do
        Sidekiq::Cron::Job.create(name: 'Foo', klass: 'Bar', cron: '1 * * * *')

        assert_includes(Workarea.redis.keys('cron_job:*'), 'cron_job:Foo')
        refute_nil(Sidekiq::Cron::Job.find('Foo'))

        ScheduledJobs.clean

        refute_includes(Workarea.redis.keys('cron_job:*'), 'cron_job:Foo')
        assert_nil(Sidekiq::Cron::Job.find('Foo'))
      end
    end

    def test_redis_not_available
      Workarea.stubs(skip_services?: true)
      assert_nil(ScheduledJobs.clean)
    end
  end
end
