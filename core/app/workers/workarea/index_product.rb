module Workarea
  class IndexProduct
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: { Catalog::Product => [:save, :save_release_changes, :destroy] },
      lock: :until_executing
    )

    class << self
      def perform(product)
        BulkIndexProducts.perform_by_model(product)
      end
    end

    def perform(id)
      self.class.perform(Catalog::Product.find(id))
    rescue Mongoid::Errors::DocumentNotFound
      Search::Storefront::Product.new(
        Catalog::Product.new(id: id)
      ).destroy
    end
  end
end
