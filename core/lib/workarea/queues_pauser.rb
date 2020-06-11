module Workarea
  module QueuesPauser
    extend self

    def pause_queues!
      pauser = Sidekiq::Throttled::QueuesPauser.instance
      queues.each { |queue| pauser.pause!(queue) }
    end

    def resume_queues!
      pauser = Sidekiq::Throttled::QueuesPauser.instance
      queues.each { |queue| pauser.resume!(queue) }
    end

    def with_paused_queues(&block)
      pause_queues!
      yield
    ensure
      resume_queues!
    end

    def queues
      Configuration::Sidekiq.queues
    end
  end
end
