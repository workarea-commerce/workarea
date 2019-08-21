require 'test_helper'

module Workarea
  module Storefront
    class FulfillmentSystemTest < Workarea::SystemTest
      setup :set_order_id
      setup :set_email
      setup :set_tracking_number
      setup :set_order
      setup :set_order_item_id

      def set_order_id
        @order_id = '1234'
      end

      def set_email
        @email = 'bcrouse@workarea.com'
      end

      def set_tracking_number
        @tracking_number = '1Z94835W3106284599'
      end

      def set_order
        @order = create_placed_order(id: @order_id, email: @email)
      end

      def set_order_item_id
        @order_item_id = @order.items.first.id.to_s
      end

      def test_completed_shipping_updates_the_fulfillment_status_of_the_order
        fulfillment = Fulfillment.find(@order.id)
        fulfillment.ship_items(@tracking_number, [
          { 'id' => @order_item_id, 'quantity' => 2 }
        ])

        order = Fulfillment.find(@order_id)
        assert_equal(:shipped, order.status)

        if Workarea.config.send_transactional_emails
          delivery = ActionMailer::Base.deliveries.last
          assert_includes(delivery.to, @email)
        end
      end

      def test_partial_shipment_updates_the_fulfillment_status_of_the_order
        fulfillment = Fulfillment.find(@order.id)
        fulfillment.ship_items(@tracking_number, [
          { 'id' => @order_item_id, 'quantity' => 1 }
        ])

        order = Fulfillment.find(@order_id)
        assert_equal(:partially_shipped, order.status)

        if Workarea.config.send_transactional_emails
          delivery = ActionMailer::Base.deliveries.last
          assert_includes(delivery.to, @email)
        end
      end

      def test_canceled_order_updates_the_fulfillment_status_of_the_order
        fulfillment = Fulfillment.find(@order.id)
        fulfillment.cancel_items(['id' => @order_item_id, 'quantity' => 2])

        order = Fulfillment.find(@order_id)
        assert_equal(:canceled, order.status)

        if Workarea.config.send_transactional_emails
          delivery = ActionMailer::Base.deliveries.last
          assert_includes(delivery.subject, 'Cancellation')
          assert_includes(delivery.to, @email)
          assert_includes(delivery.html_part.body, @order.items.first.sku)
        end
      end
    end
  end
end
