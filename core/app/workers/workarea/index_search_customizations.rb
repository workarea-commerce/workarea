module Workarea
  class IndexSearchCustomizations
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: {
        Search::Customization => [:save, :save_release_changes, :destroy],
        with: -> { [product_ids] }
      },
      lock: :until_executing,
      query_cache: true
    )

    def perform(product_ids)
      BulkIndexProducts.perform(product_ids)
    end
  end
end
