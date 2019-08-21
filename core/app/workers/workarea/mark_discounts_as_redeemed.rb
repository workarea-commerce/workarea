module Workarea
  class MarkDiscountsAsRedeemed
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options enqueue_on: { Order => :place }, queue: 'low'

    def perform(order_id)
      order = Order.find(order_id)
      shippings = Shipping.where(order_id: order_id).to_a
      mark_redeemed(order, shippings)
    end

    def mark_redeemed(order, shippings)
      discount_ids = order.discount_ids + shippings.map(&:discount_ids).flatten

      discount_ids.each do |applied_discount_id|
        discount = Pricing::Discount.find(applied_discount_id)
        discount.log_redemption(order.email)
        discount.touch
      end

      Pricing::Discount::GeneratedPromoCode
        .in(code: order.promo_codes.map(&:strip).map(&:downcase))
        .asc(:created_at)
        .uniq { |code| code.code_list_id.to_s }
        .each(&:used!)
    end
  end
end
