module Workarea
  class Scheduler
    attr_reader :job_id

    def self.schedule(*args)
      instance = new(*args)
      instance.perform
      instance.job_id
    end

    def self.delete(job_id)
      new(job_id: job_id).delete
    end

    def initialize(options = {})
      @time = options[:at]
      @worker = options[:worker]
      @args = options[:args]
      @job_id = options[:job_id]
    end

    def perform
      delete
      add_job
    end

    def delete
      current_job.try(:delete)
    end

    def add_job
      @job_id = @worker.perform_at(@time, *@args)
    end

    private

    def current_job
      return nil if job_id.blank?

      @current_job ||=
        Sidekiq::ScheduledSet.new.detect { |j| j.jid == job_id }
    end
  end
end
