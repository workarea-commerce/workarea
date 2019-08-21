module Workarea
  class PublishBulkAction
    include Sidekiq::Worker

    sidekiq_options(queue: 'low', retry: false)

    def perform(id)
      update = BulkAction.find(id)
      update.perform!
    ensure
      update.completed!
    end
  end
end
