require 'test_helper'

module Workarea
  class OrderReminderTest < IntegrationTest
    setup do
      @product = create_product
    end

    def test_sending_an_email_for_every_order
      pass && (return) unless Workarea.config.send_transactional_emails

      101.times do |i|
        Order.create!(
          email: "mdalton-#{i}@workarea.com",
          checkout_started_at: Time.current - 2.hours,
          items: [{ product_id: @product.id, sku: @product.skus.first }]
        )
      end

      OrderReminder.new.perform
      assert_equal(ActionMailer::Base.deliveries.length, 101)
    end

    def test_setting_reminded_on_orders
      order_one = Order.create!(
        email: "mdalton-1@workarea.com",
        checkout_started_at: Time.current - 2.hours,
        items: [{ product_id: @product.id, sku: @product.skus.first }]
      )
      order_two = Order.create!(
        email: "mdalton-2@workarea.com",
        checkout_started_at: Time.current - 2.hours,
        items: [{ product_id: @product.id, sku: @product.skus.first }]
      )

      OrderReminder.new.perform

      order_one.reload
      assert(order_one.reminded_at.present?)

      order_two.reload
      assert(order_two.reminded_at.present?)
    end
  end
end
