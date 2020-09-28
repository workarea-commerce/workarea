require 'test_helper'

module Workarea
  module Storefront
    class StoreCreditIntegrationTest < Workarea::IntegrationTest
      include Storefront::IntegrationTest

      setup :setup_supporting_data

      def setup_supporting_data
        @user = create_user(email: 'bcrouse@workarea.com', password: 'W3bl1nc!')

        @tax = create_tax_category(
          name: 'Sales Tax',
          code: '001',
          rates: [{ percentage: 0.07, country: 'US', region: 'PA' }]
        )

        @product = create_product(
          name: 'Integration Product',
          variants: [
            { sku: 'SKU1',
              regular: 6.to_m,
              tax_code: '001',
              on_sale: true,
              sale: 5.to_m }
          ]
        )

        @shipping_service = create_shipping_service(
          carrier: 'UPS',
          name: 'Ground',
          service_code: '03',
          tax_code: '001',
          rates: [{ price: 7.to_m }]
        )

        @payment_profile = Payment::Profile.lookup(
          PaymentReference.new(@user)
        ).tap { |p| p.update_attributes(store_credit: 5.to_m) }
      end

      def test_saving_order_info
        complete_checkout('bcrouse@workarea.com', 'W3bl1nc!')

        order = Order.first

        assert_equal('bcrouse@workarea.com', order.email)
        refute(order.placed_at.blank?)
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
        assert_equal(13.19.to_m, payment.credit_card.amount)
        refute(payment.credit_card.token.blank?)
        assert_equal(1, payment.credit_card.transactions.length)
        refute(payment.credit_card.transactions.first.response.blank?)
        assert_equal(13.19.to_m, payment.credit_card.transactions.first.amount)

        assert_equal(5.to_m, payment.store_credit.amount)
        assert_equal(1, payment.store_credit.transactions.length)
        assert_equal(5.to_m, payment.store_credit.transactions.first.amount)
      end

      def test_reducing_store_credit_balance
        complete_checkout('bcrouse@workarea.com', 'W3bl1nc!')

        @payment_profile.reload
        assert_equal(0.to_m, @payment_profile.store_credit)
      end
    end
  end
end
