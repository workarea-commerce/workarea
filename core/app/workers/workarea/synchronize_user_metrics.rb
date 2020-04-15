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

      Metrics::User.collection.update_one(
        { _id: user.email },
        {
          '$set' => {
            admin: user.admin?,
            tags: user.tags,
            updated_at: Time.current.utc
          }
        },
        upsert: true
      )
    end
  end
end
