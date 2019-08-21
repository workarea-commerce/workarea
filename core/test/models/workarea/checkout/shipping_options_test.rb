require 'test_helper'

module Workarea
  class Checkout
    class ShippingOptionsTest < TestCase
      setup :shipping_service, :setup_order

      def order
        @order ||= Order.new(
          email: 'user@workarea.com',
          items: [{ product_id: 'PRODUCT', sku: 'SKU' }]
        )
      end

      def shipping
        @shipping ||= Shipping.new(
          order_id: order.id,
          address: {
            first_name: 'Ben',
            last_name: 'Crouse',
            street: '22 S. 3rd St.',
            street_2: 'Second Floor',
            city: 'Philadelphia',
            region: 'PA',
            postal_code: '19106',
            country: 'US',
            phone_number: '2159251800'
          }
        )
      end

      def shipping_options
        @shipping_options ||= ShippingOptions.new(order, shipping)
      end

      def shipping_service
        @shipping_service ||= create_shipping_service
      end

      def setup_order
        create_shipping_service
        create_pricing_sku(id: 'SKU', prices: [{ regular: 5.to_m }])
      end

      def test_available
        options = shipping_options.available
        assert_equal(ShippingOption, options.first.class)
      end

      def test_valid?
        refute(shipping_options.valid?)

        attrs = shipping_options.available.first.to_h
        shipping.apply_shipping_service(attrs)
        assert(shipping_options.valid?)
        assert(shipping.errors[:shipping_service].blank?)

        shipping.shipping_service.name = 'asdf'
        refute(shipping_options.valid?)
        assert(shipping.errors[:shipping_service].present?)

        attrs = shipping_options.available.first.to_h
        attrs[:base_price] = 0

        shipping.apply_shipping_service(attrs)
        refute(shipping_options.valid?)
        assert(shipping.errors[:shipping_service].present?)
      end
    end
  end
end
