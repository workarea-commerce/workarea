require 'test_helper'

module Workarea
  module Storefront
    class OrdersSystemTest < Workarea::SystemTest
      setup :set_user
      setup :set_order
      setup :set_fulfillment

      def set_user
        @user = create_user(email: 'existing-account@workarea.com', password: 'W3bl1nc!')
      end

      def set_order
        @order = create_placed_order(
          id: '1234',
          email: 'existing-account@workarea.com',
          user_id: @user.id
        )
      end

      def set_fulfillment
        create_fulfillment = CreateFulfillment.new(@order)
        create_fulfillment.perform
        create_fulfillment.fulfillment.ship_items('1Z111', [
          { 'id' => @order.items.first.id, 'quantity' => @order.items.first.quantity }
        ])
      end

      def test_returning_customer
        visit storefront.check_orders_path

        within '#login_form' do
          fill_in 'email', with: 'existing-account@workarea.com'
          fill_in 'password', with: 'W3bl1nc!'
          click_button t('workarea.storefront.users.login')
        end

        assert(page.has_content?(@order.id))
        assert(page.has_content?(t('workarea.storefront.orders.track_package')))

        assert_current_path(storefront.users_orders_path)
      end

      def test_single_order_lookup
        visit storefront.check_orders_path

        within '#single_order_lookup_form' do
          fill_in 'order_id', with: '1234'
          fill_in 'postal_code', with: '19106'
          click_button t('workarea.storefront.orders.lookup_order')
        end

        assert_current_path(storefront.order_path('1234'))

        assert(page.has_content?('1234'))
        assert(page.has_content?('Shipped'))
        assert(page.has_content?(t('workarea.storefront.orders.track_package')))
      end

      def test_showing_refunds
        payment = Payment.find(@order.id)
        amounts = payment.tenders.reduce({}) { |m, t| m.merge(t.id => t.amount) }

        Payment::Capture.new(payment: payment, amounts: amounts).complete!
        Payment::Refund.new(payment: payment, amounts: amounts).complete!

        visit storefront.check_orders_path

        within '#single_order_lookup_form' do
          fill_in 'order_id', with: '1234'
          fill_in 'postal_code', with: '19106'
          click_button t('workarea.storefront.orders.lookup_order')
        end

        assert_current_path(storefront.order_path('1234'))

        assert(page.has_content?('1234'))
        assert(page.has_content?(t('workarea.storefront.orders.refunds')))
        assert(page.has_content?(t('workarea.storefront.orders.issued')))
      end
    end
  end
end
