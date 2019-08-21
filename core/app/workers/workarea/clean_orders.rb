module Workarea
  class CleanOrders
    include Sidekiq::Worker

    def perform(*)
      Order.expired.delete_all
      Order.expired_in_checkout.delete_all
    end
  end
end
