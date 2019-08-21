module Workarea
  class KeepProductIndexFresh
    include Sidekiq::Worker

    sidekiq_options(
      lock: :until_executing,
      retry: false
    )

    def perform(*args)
      all = never_indexed + stale
      BulkIndexProducts.perform_by_models(all.take(Workarea.config.stale_products_size))
    end

    def never_indexed
      Catalog::Product
        .where(last_indexed_at: nil)
        .limit(Workarea.config.stale_products_size)
        .to_a
    end

    def stale
      Catalog::Product
        .asc(:last_indexed_at)
        .limit(Workarea.config.stale_products_size)
        .to_a
    end
  end
end
