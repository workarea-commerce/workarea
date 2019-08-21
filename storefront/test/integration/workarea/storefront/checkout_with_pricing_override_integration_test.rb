require 'test_helper'

module Workarea
  module Storefront
    class CheckoutWithPricingOverrideIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest
      include Storefront::IntegrationTest

      setup :setup_order

      def setup_order
        admin_user.update_attributes!(email: 'csr@workarea.com')

        shipping_service = create_shipping_service
        product = create_product(variants: [{ sku: 'SKU', regular: 5.to_m }])

        post storefront.cart_items_path,
             params: {
               product_id: product.id,
               sku: product.skus.first,
               quantity: 2
             }

        @order = Order.not_placed.first
        checkout = Workarea::Checkout.new(@order)
        checkout.update(
          factory_defaults(:checkout_payment).merge(
            shipping_address: factory_defaults(:shipping_address),
            billing_address: factory_defaults(:billing_address),
            shipping_service: shipping_service.name,
          )
        )
      end

      def test_checking_out_with_adjusted_order_subtotal
        product = create_product(variants: [{ sku: 'SKU2', regular: 5.to_m }])
        @order.add_item(product_id: product.id, sku: 'SKU2', quantity: 1)

        override = Pricing::Override.find_or_create_by!(id: @order.id)

        override.update_attributes!(
          subtotal_adjustment: -6.to_m,
          shipping_adjustment: -0.6.to_m
        )

        patch storefront.checkout_place_order_path,
              params: {
                payment: 'new_card',
                credit_card: {
                  number: '1',
                  month: '1',
                  year: Time.now.year + 1,
                  cvv: '999'
                }
              }

        @order.reload
        shipping = Shipping.where(order_id: @order.id).first

        assert_equal(9.4.to_m, @order.total_price)
        assert_equal(0.4.to_m, @order.shipping_total)

        item = @order.items.first
        assert_equal(10.to_m, item.price_adjustments.first.amount)
        assert_equal(-4.to_m, item.price_adjustments.second.amount)
        assert_equal(
          I18n.t('workarea.pricing_overrides.description'),
          item.price_adjustments.second.description
        )

        item = @order.items.second
        assert_equal(5.to_m, item.price_adjustments.first.amount)
        assert_equal(-2.to_m, item.price_adjustments.second.amount)
        assert_equal(
          I18n.t('workarea.pricing_overrides.description'),
          item.price_adjustments.second.description
        )

        assert_equal(1.to_m, shipping.price_adjustments.first.amount)
        assert_equal(-0.6.to_m, shipping.price_adjustments.second.amount)
        assert_equal(
          I18n.t('workarea.pricing_overrides.description'),
          shipping.price_adjustments.second.description
        )
      end

      def test_checking_out_with_adjusted_order_items
        product = create_product(variants: [{ sku: 'SKU2', regular: 5.to_m }])
        @order.add_item(product_id: product.id, sku: 'SKU2', quantity: 1)

        override = Pricing::Override.find_or_create_by!(id: @order.id)

        override.update_attributes!(
          shipping_adjustment: -0.6.to_m,
          item_prices: {
            @order.items.first.id.to_s => 2.25,
            @order.items.second.id.to_s => 1.75,
          }
        )

        patch storefront.checkout_place_order_path,
              params: {
                payment: 'new_card',
                credit_card: {
                  number: '1',
                  month: '1',
                  year: Time.now.year + 1,
                  cvv: '999'
                }
              }

        @order.reload
        shipping = Shipping.where(order_id: @order.id).first

        assert_equal(6.65.to_m, @order.total_price)
        assert_equal(6.25.to_m, @order.subtotal_price)
        assert_equal(0.4.to_m, @order.shipping_total)

        item = @order.items.first
        assert_equal(10.to_m, item.price_adjustments.first.amount)
        assert_equal(-5.5.to_m, item.price_adjustments.second.amount)
        assert_equal(
          I18n.t('workarea.pricing_overrides.description'),
          item.price_adjustments.second.description
        )

        item = @order.items.second
        assert_equal(5.to_m, item.price_adjustments.first.amount)
        assert_equal(-3.25.to_m, item.price_adjustments.second.amount)
        assert_equal(
          I18n.t('workarea.pricing_overrides.description'),
          item.price_adjustments.second.description
        )

        assert_equal(1.to_m, shipping.price_adjustments.first.amount)
        assert_equal(-0.6.to_m, shipping.price_adjustments.second.amount)
        assert_equal(
          I18n.t('workarea.pricing_overrides.description'),
          shipping.price_adjustments.second.description
        )
      end

      def test_checking_out_with_order_set_to_be_free
        override = Pricing::Override.find_or_create_by!(id: @order.id)

        override.update_attributes!(
          subtotal_adjustment: -1 * @order.subtotal_price,
          shipping_adjustment: -1 * @order.shipping_total
        )

        patch storefront.checkout_place_order_path

        @order.reload
        shipping = Shipping.where(order_id: @order.id).first

        assert_equal(0.to_m, @order.total_price)
        assert_equal(0.to_m, @order.shipping_total)

        item = @order.items.first
        assert_equal(10.to_m, item.price_adjustments.first.amount)
        assert_equal(-10.to_m, item.price_adjustments.second.amount)

        assert_equal(1.to_m, shipping.price_adjustments.first.amount)
        assert_equal(-1.to_m, shipping.price_adjustments.second.amount)
      end
    end
  end
end
