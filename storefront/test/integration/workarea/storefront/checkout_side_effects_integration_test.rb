require 'test_helper'

module Workarea
  module Storefront
    class CheckoutSideEffectsIntegrationTest < Workarea::IntegrationTest
      include Storefront::IntegrationTest

      def test_sending_confirmation_email
        pass && (return) unless Workarea.config.send_transactional_emails

        recommendation_product = create_product
        create_top_products(results: [{ 'product_id' => recommendation_product.id }])
        complete_checkout

        order = Order.first

        email = ActionMailer::Base.deliveries.last

        email.parts.each do |part|
          body = part.body.to_s

          assert_match(order.id, body)
          assert_match(product.name, body)

          if part.content_type =~ /html/
            assert_match(recommendation_product.name, body)
            assert_match(recommendation_product.to_param, body)
          end
        end

        assert_match('Confirmation', email.subject.to_s)
        assert_match('bcrouse@workarea.com', email.to.to_s)
      end

      def test_order_fulfillment_creation
        complete_checkout

        order = Order.first
        fulfillment = Fulfillment.find(order.id)

        assert_equal(
          order.items.first.id.to_s,
          fulfillment.items.first.order_item_id
        )
        assert_equal(2, fulfillment.items.first.quantity)
      end

      def test_saving_user_info
        user = create_user(
          email: 'bcrouse@workarea.com',
          password: 'W3bl1nc!',
          first_name: nil,
          last_name: nil
        )

        complete_checkout('bcrouse@workarea.com', 'W3bl1nc!')

        user.reload
        assert_equal('Ben', user.first_name)
        assert_equal('Crouse', user.last_name)

        metrics = Metrics::User.first
        assert_equal(1, metrics.orders)
        assert_equal(17, metrics.revenue)
        assert_equal(17, metrics.average_order_value)
        refute(metrics.last_order_at.blank?)

        payment_profile = Payment::Profile.lookup(PaymentReference.new(user))
        assert_equal(1, payment_profile.credit_cards.length)

        credit_card = payment_profile.credit_cards.first
        assert_equal('Test Card', credit_card.issuer)
        assert_equal('Ben', credit_card.first_name)
        assert_equal('Crouse', credit_card.last_name)
        assert_equal('XXXX-XXXX-XXXX-1', credit_card.display_number)
        assert_equal(1, credit_card.month)
        assert_equal(next_year, credit_card.year)
        refute(credit_card.token.blank?)

        complete_checkout('bcrouse@workarea.com', 'W3bl1nc!')

        metrics.reload
        assert_equal(2, metrics.orders)
        assert_equal(34, metrics.revenue)
        assert_equal(17, metrics.average_order_value)
      end

      def test_saving_guest_info_from_account_creation
        complete_checkout

        post storefront.users_account_path,
          params: {
            email: 'bcrouse@workarea.com',
            password: 'W3bl1nc!'
          }

        user = User.where(email: 'bcrouse@workarea.com').first
        assert_equal('Ben', user.first_name)
        assert_equal('Crouse', user.last_name)

        metrics = Metrics::User.first
        assert_equal(1, metrics.orders)
        assert_equal(17, metrics.revenue)
        assert_equal(17, metrics.average_order_value)
        refute(metrics.last_order_at.blank?)
      end

      def test_updating_inventory
        inventory = create_inventory(id: 'SKU1', policy: 'standard', available: 0)
        complete_checkout

        inventory.reload
        assert_equal(0, inventory.purchased)
        assert_equal(0, inventory.available)

        inventory.update_attributes(policy: 'standard', available: 2)
        complete_checkout

        inventory.reload
        assert_equal(2, inventory.purchased)
        assert_equal(0, inventory.available)
      end

      def test_updating_discount_redemptions
        create_user(email: 'bcrouse@workarea.com', password: 'W3bl1nc!')

        new_product = create_product(
          name: 'Integration Product Two',
          variants: [{ sku: 'SKU2', tax_code: '001', regular: 10.to_m }]
        )

        discount = create_product_discount(
          name: 'Test Discount',
          amount_type: 'flat',
          amount: 1,
          product_ids: [new_product.id]
        )

        post storefront.cart_items_path,
          params: {
            product_id: new_product.id,
            sku: new_product.skus.first,
            quantity: 2
          }

        complete_checkout('bcrouse@workarea.com', 'W3bl1nc!')

        discount.reload
        assert_equal(1, discount.redemptions.length)
        assert_equal('bcrouse@workarea.com', discount.redemptions.first.email)
      end

      def test_updating_metrics
        create_life_cycle_segments
        create_user(email: 'bcrouse@workarea.com', password: 'W3bl1nc!')
        create_tax_category(code: '001', rates: [{ percentage: 0.06, country: 'US' }])
        create_order_total_discount(amount_type: 'percent', amount: 10)
        complete_checkout('bcrouse@workarea.com', 'W3bl1nc!')

        product = Metrics::ProductByDay.first
        assert_equal(1, product.orders)
        assert_equal(2, product.units_sold)
        assert_equal(2, product.discounted_units_sold)
        assert_equal(10, product.merchandise)
        assert_equal(-1, product.discounts)
        assert_equal(0.54, product.tax)
        assert_equal(9.54, product.revenue)

        discount = Metrics::DiscountByDay.first
        assert_equal(1, discount.orders)
        assert_equal(10, discount.merchandise)
        assert_equal(-1, discount.discounts)
        assert_equal(16.96, discount.revenue)

        country = Metrics::CountryByDay.first
        assert_equal(1, country.orders)
        assert_equal(2, country.units_sold)
        assert_equal(2, country.discounted_units_sold)
        assert_equal(10, country.merchandise)
        assert_equal(-1, country.discounts)
        assert_equal(7, country.shipping)
        assert_equal(0.96, country.tax)
        assert_equal(16.96, country.revenue)

        sales = Metrics::SalesByDay.first
        assert_equal(1, sales.orders)
        assert_equal(0, sales.returning_orders)
        assert_equal(1, sales.customers)
        assert_equal(2, sales.units_sold)
        assert_equal(2, sales.discounted_units_sold)
        assert_equal(10, sales.merchandise)
        assert_equal(-1, sales.discounts)
        assert_equal(7, sales.shipping)
        assert_equal(0.96, sales.tax)
        assert_equal(16.96, sales.revenue)

        sku = Metrics::SkuByDay.first
        assert_equal(1, sku.orders)
        assert_equal(2, sku.units_sold)
        assert_equal(2, sku.discounted_units_sold)
        assert_equal(10, sku.merchandise)
        assert_equal(-1, sku.discounts)
        assert_equal(0.54, sku.tax)
        assert_equal(9.54, sku.revenue)

        user = Metrics::User.first
        assert_equal(1, user.orders)
        assert_equal(16.96, user.revenue)
        assert_equal(-1, user.discounts)
        assert_kind_of(Time, user.first_order_at)
        assert_kind_of(Time, user.last_order_at)
        assert_equal(1, user.purchased.product_ids.size)

        segment = Metrics::SegmentByDay.first
        assert_equal(1, segment.orders)
        assert_equal(0, segment.returning_orders)
        assert_equal(1, segment.customers)
        assert_equal(2, segment.units_sold)
        assert_equal(2, segment.discounted_units_sold)
        assert_equal(10, segment.merchandise)
        assert_equal(-1, segment.discounts)
        assert_equal(7, segment.shipping)
        assert_equal(0.96, segment.tax)
        assert_equal(16.96, segment.revenue)
      end
    end
  end
end
