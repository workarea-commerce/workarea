module Workarea
  class IndexSkus
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: {
        Inventory::Sku => [:touch, :save, :destroy],
        Pricing::Sku => [:touch, :save, :destroy]
      },
      lock: :until_executing
    )

    def perform(sku)
      Catalog::Product.find_for_update_by_sku(sku).each do |product|
        IndexProduct.perform(product)
      end
    end
  end
end
