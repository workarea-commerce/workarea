module Workarea
  module QueuesPauser
    extend self

    # Pause all Sidekiq queues defined in the Workarea configuration.
    #
    # Queue pausing requires either Sidekiq Pro or sidekiq-throttled <= 0.x.
    # sidekiq-throttled 1.x removed QueuesPauser; Sidekiq 7 OSS only stubs
    # #paused? (always returns false) and has no pause! / resume! methods.
    #
    # When a compatible pauser is unavailable this method is a no-op so that
    # code paths that use it (e.g. search re-indexing tasks) continue to work
    # without crashing.
    def pause_queues!
      if defined?(::Sidekiq::Throttled::QueuesPauser)
        # sidekiq-throttled <= 0.x API
        pauser = ::Sidekiq::Throttled::QueuesPauser.instance
        queues.each { |queue| pauser.pause!(queue) }
      else
        # Sidekiq 7 OSS + sidekiq-throttled 1.x: attempt built-in pause API
        # (available in Sidekiq Pro; silently skipped when unavailable).
        queues.each do |queue_name|
          q = ::Sidekiq::Queue.new(queue_name)
          q.pause! if q.respond_to?(:pause!)
        end
      end
    end

    # Resume all Workarea queues. See #pause_queues! for compatibility notes.
    def resume_queues!
      if defined?(::Sidekiq::Throttled::QueuesPauser)
        pauser = ::Sidekiq::Throttled::QueuesPauser.instance
        queues.each { |queue| pauser.resume!(queue) }
      else
        queues.each do |queue_name|
          q = ::Sidekiq::Queue.new(queue_name)
          q.unpause! if q.respond_to?(:unpause!)
        end
      end
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
