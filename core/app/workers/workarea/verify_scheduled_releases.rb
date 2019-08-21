module Workarea
  # Verify that jobs for publishing releases do not get removed
  # unintentionally from Sidekiq and prevent the release from updating at the
  # expected time. If any are found missing, add a new job.
  # Runs hourly by default, 5 minutes before each hour.
  #
  class VerifyScheduledReleases
    include Sidekiq::Worker
    sidekiq_options queue: 'releases'

    def perform(*)
      # PublishRelease uses the default queue,
      # so only look there for scheduled release jobs
      job_ids = Sidekiq::Queue.new.map { |job| job.jid }
      now = Time.current

      Release.all.each do |release|
        if release.scheduled? &&
           release.publish_at > now &&
           !job_ids.include?(release.publish_job_id)

          release.set_publish_job
          release.save!
        end
      end
    end
  end
end
