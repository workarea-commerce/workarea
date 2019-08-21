module Workarea
  class IndexSkus
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: {
        Inventory::Sku => [:touch, :save, :save_release_changes, :destroy],
        Pricing::Sku => [:touch, :save, :save_release_changes, :destroy]
      },
      lock: :until_executing
    )

    def perform(sku)
      BulkIndexProducts.perform_by_models(Catalog::Product.find_for_update_by_sku(sku))
    end
  end
end
