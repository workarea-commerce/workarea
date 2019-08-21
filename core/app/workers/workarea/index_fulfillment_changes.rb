module Workarea
  class IndexFulfillmentChanges
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: { Fulfillment => :save }, queue: 'low',
      lock: :until_executing
    )

    def perform(order_id)
      order = Order.find(order_id) rescue nil
      IndexAdminSearch.perform(order) if order.present?
    end
  end
end
