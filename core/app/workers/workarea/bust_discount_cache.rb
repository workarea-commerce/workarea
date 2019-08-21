module Workarea
  class BustDiscountCache
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: { Pricing::Discount => [:save, :destroy] },
      queue: 'low',
      retry: false
    )

    def perform(*)
      Pricing::Discount::ApplicationGroup.expire_cache
    end
  end
end
