module Workarea
  class SynchronizeUserMetrics
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: { User => :save, only_if: -> { admin_changed? || tags_changed? } },
      queue: 'low'
    )

    # It's essential for the {Metrics::User#admin} field always be in sync, so
    # we always want this worker enabled.
    #
    # @return [Boolean]
    #
    def self.enabled?
      true
    end

    def perform(id)
      user = User.find(id)
      metrics = Metrics::User.find_or_create_by(id: user.email)
      metrics.set(admin: user.admin?, tags: user.tags)
    end
  end
end
