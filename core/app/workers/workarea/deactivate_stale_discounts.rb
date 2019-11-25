module Workarea
  class DeactivateStaleDiscounts
    include Sidekiq::Worker

    def perform(*args)
      Mongoid::AuditLog.record do
        Pricing::Discount.any_in(id: unused_discount_ids).auto_deactivate
      end
    end

    def unused_discount_ids
      all_active_discount_ids - used_discount_ids
    end

    def used_discount_ids
      @used_discount_ids ||=
        (order_discount_ids + shipping_discount_ids).map(&:to_s).uniq
    end

    def order_discount_ids
      Order.since(Workarea.config.discount_staleness_ttl.ago).discount_ids
    end

    def shipping_discount_ids
      Shipping
        .since(Workarea.config.discount_staleness_ttl.ago)
        .discount_ids
    end

    def all_active_discount_ids
      Pricing::Discount
        .where(:updated_at.lt => Workarea.config.discount_staleness_ttl.ago)
        .select(&:active?)
        .map(&:id)
        .map(&:to_s)
    end
  end
end
