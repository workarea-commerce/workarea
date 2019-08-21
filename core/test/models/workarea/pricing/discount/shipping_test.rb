require 'test_helper'

module Workarea
  module Pricing
    class Discount
      class ShippingTest < TestCase
        include DiscountConditionTests::OrderTotal
        include DiscountConditionTests::PromoCodes

        def qualified_discount
          @qualified_discount ||= Shipping.new(shipping_service: 'Ground')
        end
        alias_method :order_total_discount, :qualified_discount
        alias_method :promo_codes_discount, :qualified_discount

        def discounted_order
          @discounted_order ||= Workarea::Order.new.tap do |order|
            shipping = Workarea::Shipping.new(order_id: order.id)
            shipping.set_shipping_service(
              name: 'Ground',
              base_price: 10.to_m
            )
          end
        end

        def order
          @order ||= Workarea::Order.new
        end

        def shipping
          @shipping ||= Workarea::Shipping.new.tap do |shipping|
            shipping.set_shipping_service(
              name: 'Ground',
              base_price: 10.to_m
            )
          end
        end

        def discount_order
          @discount_order ||= Discount::Order.new(order, shipping)
        end

        def test_matching_shipping_service?
          discount = Shipping.new(shipping_service: 'Next Day')
          refute(discount.matching_shipping_service?(discount_order))

          discount = Shipping.new(shipping_service: 'Ground')
          assert(discount.matching_shipping_service?(discount_order))
        end

        def test_apply
          discount = Shipping.new(amount: 7.to_m, shipping_service: 'Ground')
          discount.apply(discount_order)

          price_adjustment = shipping.price_adjustments.last
          assert_equal(-3.to_m, price_adjustment.amount)

          shipping.reset_adjusted_shipping_pricing
          discount = Shipping.new(amount: 11.to_m, shipping_service: 'Ground')
          discount.apply(discount_order)

          assert_equal(1, shipping.price_adjustments.length)
        end
      end
    end
  end
end
