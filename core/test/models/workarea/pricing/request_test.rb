require 'test_helper'

module Workarea
  module Pricing
    class RequestTest < TestCase
      setup :create_request

      def create_request
        @tax = create_tax_category

        @pricing = create_pricing_sku(
          id: 'SKU',
          tax_code: @tax.code,
          prices: [{ regular: 5.to_m }]
        )

        @order = Order.new
        @order.add_item(product_id: 'PRODUCT', sku: 'SKU', quantity: 2)
        @order.save!

        @payment = create_payment(
          id: @order.id,
          address: factory_defaults_config.billing_address
        )

        @discount = create_product_discount(promo_codes: ['promo-code'])

        @shipping = Shipping.create!(shipping_service: { name: 'Ground' })

        request = Request.new(@order, @shipping)
        request.run
        request.save!

        @request = Request.new(@order, @shipping)
      end

      def test_request_is_fresh_after_priced
        refute @request.stale?
      end

      def test_saving_with_fresh_cache
        request = Request.new(@order, @shipping)
        refute(request.stale?)

        request.save!
        refute(@order.updated_at_changed?)
        refute(@shipping.updated_at_changed?)
      end

      def test_pricing_breaks_cache
        @pricing.updated_at = Time.current + 1.minute
        @pricing.save

        assert @request.stale?
      end

      def test_discounts_break_cache
        @discount.updated_at = Time.current + 1.minute
        @discount.save

        assert @request.stale?
      end

      def test_adding_promo_code_breaks_cache
        @order.add_promo_code('promo-code')

        assert @request.stale?
      end

      def test_adding_an_order_item_breaks_cache
        @order.add_item(product_id: 'PRODUCT', sku: 'SKU2', quantity: 2)

        assert @request.stale?
      end

      def test_tax_breaks_cache
        @tax.updated_at = Time.current + 1.minute
        @tax.save

        assert @request.stale?
      end

      def test_shipping_service_select_breaks_cache
        @shipping.shipping_service.name = 'Second Day'
        @shipping.save!

        assert @request.stale?
      end

      def test_payment_breaks_cache
        @payment.address.street = '225 Arch St.'
        @payment.save!

        @request = Request.new(@order, @shipping)
        assert @request.stale?
      end
    end
  end
end
