require 'test_helper'

module Workarea
  class Checkout
    class CollectPaymentTest < TestCase
      def order
        @order ||= Order.new(email: 'test@workarea.com', total_price: 5.to_m)
      end

      def checkout
        @checkout ||= Checkout.new(order)
      end

      def collect_payment
        @collect_payment ||= CollectPayment.new(checkout)
      end

      def test_valid?
        refute(collect_payment.valid?)
        assert_equal(1, checkout.payment.errors[:base].length)
      end

      def test_purchase
        refute(collect_payment.purchase)

        order.total_price = 0.to_m
        assert(collect_payment.purchase)

        order.total_price = 5.to_m

        checkout.payment.profile = create_payment_profile(
          email: order.email,
          store_credit: 20.to_m
        )
        checkout.payment.build_store_credit(amount: 5.to_m)

        assert(collect_payment.purchase)
      end

      def test_action
        Workarea.config.checkout_payment_action = {
          shipping: 'bar!',
          partial_shipping: 'baz!',
          no_shipping: 'foo!'
        }

        order.items.build(fulfillment: 'download')
        assert_equal('foo!', collect_payment.action)

        order.items.build(fulfillment: 'shipping')
        assert_equal('baz!', collect_payment.action)

        order.items.clear
        order.items.build(fulfillment: 'shipping')
        assert_equal('bar!', collect_payment.action)
      end
    end
  end
end
