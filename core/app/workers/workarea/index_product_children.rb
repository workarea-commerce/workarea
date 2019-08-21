module Workarea
  class IndexProductChildren
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: {
        Catalog::Variant => [:save, :save_release_changes, :destroy],
        Catalog::ProductImage => [:save, :save_release_changes, :destroy],
        with: -> { [_parent.id.to_s] }
      },
      lock: :until_executing
    )

    def perform(id)
      product = Catalog::Product.find(id) rescue nil
      IndexProduct.perform(product) if product.present?
    end
  end
end
