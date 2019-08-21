module Workarea
  module ScheduledJobs
    # Remove any scheduled jobs that still exist in Redis, but no longer
    # have a worker class available for them. Fixes an issue wherein
    # removing a previously scheduled job from initializers doesn't
    # actually stop the job from being enqueued.
    def self.clean
      return if Workarea.config.skip_service_connections

      Sidekiq::Cron::Job.all.each do |job|
        job.destroy unless const_defined?(job.klass)
      end
    end
  end
end
