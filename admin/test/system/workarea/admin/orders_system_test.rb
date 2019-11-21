require 'test_helper'

module Workarea
  module Admin
    class OrdersSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_attributes
        order = create_placed_order(
          traffic_referrer: {
            uri: 'https://foo.bar'
          }
        )

        visit admin.order_path(order)
        click_link t('workarea.admin.cards.attributes.title')

        assert(page.has_content?('Test Product'))
        assert(page.has_content?('SKU'))
        assert(page.has_content?("#{Money.default_currency.symbol}10.00")) # Subtotal
        assert(page.has_content?("#{Money.default_currency.symbol}1.00")) # Shipping
        assert(page.has_content?("#{Money.default_currency.symbol}11.00")) # Total

        click_link t('workarea.admin.orders.attributes.checkout.view')
        within '.tooltip-content' do
          page.has_content?('https://foo.bar')
        end
      end

      def test_fulfillment
        order = create_placed_order
        fulfillment = Fulfillment.find(order.id)
        fulfillment.ship_items('1z', ['id' => order.items.first.id, 'quantity' => 2])

        visit admin.order_path(order)
        click_link t('workarea.admin.orders.cards.fulfillment.title')

        assert(page.has_content?('Test Product'))
        assert(page.has_content?('SKU'))
        assert(page.has_content?('1z')) # Tracking Number
        assert(page.has_content?('2')) # Quantity
      end

      def test_shipping
        order = create_placed_order
        visit admin.order_path(order)
        click_link t('workarea.admin.orders.attributes.shipping.title')

        assert(page.has_content?('Ben Crouse'))
        assert(page.has_content?('22 S. 3rd St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('19106'))
        assert(page.has_content?('Test')) # Method Name
        assert(page.has_content?("#{Money.default_currency.symbol}1.00")) # Shipping Charges
      end

      def test_payment
        Workarea.config.checkout_payment_action = {
          shipping: 'authorize!',
          partial_shipping: 'authorize!',
          no_shipping: 'authorize!'
        }

        order = create_placed_order
        visit admin.order_path(order)
        click_link t('workarea.admin.orders.attributes.payment.title')

        assert(page.has_content?('Ben Crouse'))
        assert(page.has_content?('22 S. 3rd St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('19106'))
        assert(page.has_content?('Credit Card'))
        assert(page.has_content?('-1')) # Card Number
        assert(page.has_content?('Authorize'))
        assert(page.has_content?('Success'))
        assert(page.has_content?("#{Money.default_currency.symbol}11.00")) # Auth Amount
      end

      def test_fraud
        order = create_fraudulent_order
        visit admin.order_path(order)
        click_link t('workarea.admin.orders.attributes.fraud.title')
        assert(page.has_content?('Declined')) # decision
        assert(page.has_content?(order.fraud_decision.message))
        assert(page.has_content?(order.fraud_decision.response))
      end

      def test_timeline
        order = create_placed_order
        fulfillment = Fulfillment.find(order.id)
        fulfillment.ship_items('1z', ['id' => order.items.first.id, 'quantity' => 2])

        shipped_content = t('workarea.admin.orders.timeline.shipped', count: 2)
        auth_content = t(
          'workarea.admin.orders.timeline.authorize.success',
          type: 'credit card',
          amount: Admin::ApplicationController.helpers.number_to_currency(11.to_m)
        )

        visit admin.order_path(order)
        assert_match(t('workarea.admin.orders.timeline.placed'), page.body)
        assert_match(shipped_content, page.body)
        assert_match(auth_content, page.body)

        click_link t('workarea.admin.timeline.card.title')

        assert(page.has_content?(t('workarea.admin.orders.timeline.placed')))
        assert(page.has_content?(t('workarea.admin.orders.timeline.created')))
        assert(page.has_content?(shipped_content))
        assert(page.has_content?(auth_content))
      end

      def test_order_without_fulfillment
        order = create_placed_order
        Fulfillment.find(order.id).destroy
        IndexAdminSearch.perform(order)

        visit admin.orders_path
        assert(page.has_content?('Not Available'))
        click_link order.id

        assert(page.has_content?(t('workarea.admin.orders.cards.fulfillment.title')))
        assert(page.has_content?(t('workarea.admin.orders.cards.fulfillment.not_available')))
      end
    end
  end
end
