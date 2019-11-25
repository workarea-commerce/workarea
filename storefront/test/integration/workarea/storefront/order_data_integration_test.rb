require 'test_helper'

module Workarea
  module Storefront
    class OrderDataIntegrationTest < Workarea::IntegrationTest
      include Storefront::IntegrationTest

      setup :set_tax_category, :set_product, :set_shipping_service

      def set_tax_category
        create_tax_category(
          name: 'Sales Tax',
          code: '001',
          rates: [{ percentage: 0.07, country: 'US', region: 'PA' }]
        )
      end

      def set_product
        @product = create_product(
          name:     'Integration Product',
          variants: [
            { sku: 'SKU1',
              regular: 6.to_m,
              tax_code: '001',
              on_sale: true,
              sale: 5.to_m }
          ]
        )
      end

      def set_shipping_service
        @shipping_service = create_shipping_service(
          carrier: 'UPS',
          name: 'Ground',
          service_code: '03',
          tax_code: '001',
          rates: [{ price: 7.to_m }]
        )
      end

      def test_order_info_saving
        complete_checkout

        order = Order.first

        refute(order.placed_at.blank?)
        assert_equal(order.email, 'bcrouse@workarea.com')
        assert_equal('127.0.0.1', order.ip_address)
        assert_equal('Mozilla', order.user_agent)

        assert_equal(1, order.items.length)
        assert_equal(@product.id, order.items.first.product_id)
        assert_equal(@product.skus.first, order.items.first.sku)
        assert_equal(2, order.items.first.quantity)
        assert(order.items.first.product_attributes.present?)

        assert_equal(10.to_m, order.items.first.total_price)

        assert_equal(1, order.items.first.price_adjustments.length)
        assert_equal(10.to_m, order.items.first.price_adjustments.first.amount)

        assert_equal(10.to_m, order.subtotal_price)
        assert_equal(7.to_m, order.shipping_total)
        assert_equal(1.19.to_m, order.tax_total)
        assert_equal(18.19.to_m, order.total_price)

        shipping = Shipping.first

        assert_equal(3, shipping.price_adjustments.length)
        assert_equal(7.to_m, shipping.price_adjustments.first.amount)
        assert_equal(0.7.to_m, shipping.price_adjustments.second.amount)
        assert_equal(0.49.to_m, shipping.price_adjustments.third.amount)
        assert_equal(7.to_m, shipping.shipping_total)
        assert_equal(1.19.to_m, shipping.tax_total)

        assert_equal('Ben', shipping.address.first_name)
        assert_equal('Crouse', shipping.address.last_name)
        assert_equal('22 S. 3rd St.', shipping.address.street)
        assert_equal('Philadelphia', shipping.address.city)
        assert_equal('PA', shipping.address.region)
        assert_equal('19106', shipping.address.postal_code)
        assert_equal(Country['US'], shipping.address.country)
        assert_equal('2159251800', shipping.address.phone_number)

        assert_equal('UPS', shipping.shipping_service.carrier)
        assert_equal('Ground', shipping.shipping_service.name)
        assert_equal('03', shipping.shipping_service.service_code)
        assert_equal('001', shipping.shipping_service.tax_code)

        payment = Payment.find(order.id)
        assert_equal('Ben', payment.address.first_name)
        assert_equal('Crouse', payment.address.last_name)
        assert_equal('12 N. 3rd St.', payment.address.street)
        assert_equal('Philadelphia', payment.address.city)
        assert_equal('PA', payment.address.region)
        assert_equal('19106', payment.address.postal_code)
        assert_equal(Country['US'], payment.address.country)
        assert_equal('2159251800', payment.address.phone_number)

        assert_equal('Test Card', payment.credit_card.issuer)
        assert_equal('XXXX-XXXX-XXXX-1', payment.credit_card.display_number)
        assert_equal(1, payment.credit_card.month)
        assert_equal(next_year, payment.credit_card.year)
        refute(payment.credit_card.token.blank?)
        assert(payment.credit_card.saved_card_id.blank?)

        assert_equal(1, payment.credit_card.transactions.length)
        assert_equal(18.19.to_m, payment.credit_card.transactions.first.amount)
        refute(payment.credit_card.transactions.first.response.blank?)
      end

      def test_saving_user_info
        user = create_user(
          email: 'bcrouse@workarea.com',
          password: 'W3bl1nc!'
        )

        complete_checkout('bcrouse@workarea.com', 'W3bl1nc!')

        order = Order.first
        assert_equal('bcrouse@workarea.com', order.email)
        assert_equal(user.id.to_s, order.user_id)
        assert_equal(user.id.to_s, order.checkout_by_id)

        payment = Payment.find(order.id)
        refute(payment.credit_card.token.blank?)
      end

      def test_saving_item_discount_info
        discount = create_product_discount(
          name: 'Test Discount',
          amount_type: 'flat',
          amount: 3,
          promo_codes: ['PROMOCODE'],
          product_ids: [@product.id]
        )

        post storefront.add_promo_code_to_cart_path,
          params: { promo_code: 'PROMOCODE' }

        complete_checkout

        order = Order.first
        assert_equal(order.promo_codes, %w(PROMOCODE))
        assert_equal(2, order.items.first.price_adjustments.length)
        assert_equal(10.to_m, order.items.first.price_adjustments.first.amount)
        assert_equal(-6.to_m, order.items.first.price_adjustments.second.amount)
        assert_equal(discount.id.to_s, order.items.first.price_adjustments.second.data['discount_id'])

        shipping = Shipping.first
        assert_equal(3, shipping.price_adjustments.length)
        assert_equal(0.28.to_m, shipping.price_adjustments.second.amount)
      end

      def test_saving_free_items
        create_product(
          name: 'Free Product',
          variants: [{ sku: 'FREE_SKU', regular: 5.to_m }]
        )

        discount = create_free_gift_discount(
          name: 'Free Gift!',
          sku: 'FREE_SKU',
          promo_codes: ['PROMOCODE']
        )

        post storefront.add_promo_code_to_cart_path,
          params: { promo_code: 'PROMOCODE' }

        complete_checkout

        order = Order.first
        assert_equal(2, order.items.length)
        assert_equal(0.to_m, order.items.second.total_price)
        assert_equal(1, order.items.second.price_adjustments.length)
        assert_equal(0.to_m, order.items.second.price_adjustments.first.amount)
        assert_equal(discount.id.to_s, order.items.second.price_adjustments.first.data['discount_id'])
      end

      def test_saving_shipping_discounts
        create_shipping_discount(
          name: 'Test Discount',
          amount: 1.to_m,
          shipping_service: @shipping_service.name,
          promo_codes: ['PROMOCODE']
        )

        post storefront.add_promo_code_to_cart_path,
          params: { promo_code: 'PROMOCODE' }

        complete_checkout

        shipping = Shipping.first

        assert_equal(4, shipping.price_adjustments.length)
        assert_equal(7.to_m, shipping.price_adjustments.first.amount)
        assert_equal(-6.to_m, shipping.price_adjustments.second.amount)
        assert_equal(0.7.to_m, shipping.price_adjustments.third.amount)
        assert_equal(0.07.to_m, shipping.price_adjustments.fourth.amount)
      end

      def test_saving_order_discounts
        discount = create_order_total_discount(
          name: 'Discount',
          amount_type: 'flat',
          amount: 3,
          promo_codes: ['PROMOCODE']
        )

        post storefront.add_promo_code_to_cart_path,
          params: { promo_code: 'PROMOCODE' }

        complete_checkout

        order = Order.first

        assert_equal(2, order.items.first.price_adjustments.length)
        assert_equal(10.to_m, order.items.first.price_adjustments.first.amount)
        assert_equal(-3.to_m, order.items.first.price_adjustments.second.amount)
        assert_equal(discount.id.to_s, order.items.first.price_adjustments.second.data['discount_id'])

        shipping = Shipping.first

        assert_equal(3, shipping.price_adjustments.length)
        assert_equal(7.to_m, shipping.price_adjustments.first.amount)
        assert_equal(0.49.to_m, shipping.price_adjustments.second.amount)
        assert_equal(0.49.to_m, shipping.price_adjustments.third.amount)
      end

      def test_not_merging_free_item_when_resuming_user_checkout
        order = Order.create!(id: 'ABC', email: 'mdalton-test@workarea.com')

        order.items.build(
          product_id: 'P1',
          sku: 'SKU1',
          quantity: 1
        )

        order.items.build(
          product_id: 'P2',
          sku: 'SKU2',
          quantity: 1,
          free_gift: true
        )

        order.save!

        get storefront.resume_cart_path(order.token)

        assert_equal('P1', Order.first.items.first.product_id)
        assert_equal('SKU1', Order.first.items.first.sku)
        assert_equal(1, Order.first.items.first.quantity)
      end
    end
  end
end
