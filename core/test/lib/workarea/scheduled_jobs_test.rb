require 'test_helper'

module Workarea
  class ScheduledJobsTest < TestCase
    def test_remove_dead_jobs_after_initialize
      Sidekiq::Cron::Job.create(name: 'Foo', klass: 'Bar', cron: '1 * * * *')

      assert_includes(Workarea.redis.keys('cron_job:*'), 'cron_job:Foo')
      refute_nil(Sidekiq::Cron::Job.find('Foo'))

      ScheduledJobs.clean

      refute_includes(Workarea.redis.keys('cron_job:*'), 'cron_job:Foo')
      assert_nil(Sidekiq::Cron::Job.find('Foo'))
    end

    def test_redis_not_available
      @_skip_services = Workarea.config.skip_service_connections
      Workarea.config.skip_service_connections = true

      assert_nil(ScheduledJobs.clean)
    ensure
      Workarea.config.skip_service_connections = @_skip_services
    end
  end
end
