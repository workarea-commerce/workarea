module Workarea
  class BustSkuCache
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: { Inventory::Sku => :save, Pricing::Sku => :save },
      queue: 'low',
      retry: false
    )

    def perform(sku)
      Catalog::Product.find_for_update_by_sku(sku).each(&:touch)
    end
  end
end
