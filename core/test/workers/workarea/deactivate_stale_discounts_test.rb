require 'test_helper'

module Workarea
  class DeactivateStaleDiscountsTest < TestCase
    def create_category_discount(attributes = {})
      before_ttl = (Workarea.config.discount_staleness_ttl + 1.day).ago
      super(attributes.reverse_merge(updated_at: before_ttl))
    end

    def test_perform
      used_order_discount = create_category_discount
      create_order.tap do |order|
        order.set(discount_ids: [used_order_discount.id.to_s])
      end

      used_shipping_discount = create_category_discount
      create_shipping.tap do |shipping|
        shipping.set(discount_ids: [used_shipping_discount.id.to_s])
      end

      unused_discount = create_category_discount

      DeactivateStaleDiscounts.new.perform

      used_order_discount.reload
      used_shipping_discount.reload
      unused_discount.reload

      assert(used_order_discount.active?)
      refute(used_order_discount.auto_deactivated?)

      assert(used_shipping_discount.active?)
      refute(used_shipping_discount.auto_deactivated?)

      refute(unused_discount.active?)
      assert(unused_discount.auto_deactivated?)


      create_category_discount

      assert_difference('Mongoid::AuditLog::Entry.count', 1) do
        DeactivateStaleDiscounts.new.perform
      end
    end

    def test_unused_discount_ids
      active = create_category_discount(active: true)
      inactive = create_category_discount(active: false)

      worker = DeactivateStaleDiscounts.new
      assert_includes(worker.unused_discount_ids, active.id.to_s)
      refute_includes(worker.unused_discount_ids, inactive.id.to_s)


      used_order_discount = create_category_discount
      create_order.tap do |order|
        order.set(discount_ids: [used_order_discount.id.to_s])
      end

      used_shipping_discount = create_category_discount
      create_shipping.tap do |shipping|
        shipping.set(discount_ids: [used_shipping_discount.id.to_s])
      end

      unused_discount = create_category_discount

      worker = DeactivateStaleDiscounts.new
      assert_includes(worker.unused_discount_ids, unused_discount.id.to_s)
      refute_includes(worker.unused_discount_ids, used_order_discount.id.to_s)
      refute_includes(worker.unused_discount_ids, used_shipping_discount.id.to_s)
    end

    def test_all_active_discount_ids
      too_new = create_category_discount(active: true, updated_at: Time.current)
      active = create_category_discount(active: true)

      worker = DeactivateStaleDiscounts.new
      assert_includes(worker.all_active_discount_ids, active.id.to_s)
      refute_includes(worker.all_active_discount_ids, too_new.id.to_s)
    end
  end
end
