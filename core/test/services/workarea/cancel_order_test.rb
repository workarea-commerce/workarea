require 'test_helper'

module Workarea
  class CancelOrderTest < TestCase
    setup :build_order

    def build_order
      create_product(id: 'PROD1', variants: [{ sku: 'SKU1', regular: 5.to_m }])
      create_product(id: 'PROD2', variants: [{ sku: 'SKU2', regular: 3.to_m }])

      @order = Order.new(
        email: 'test@workarea.com',
        items: [
          { product_id: 'PROD1', sku: 'SKU1', quantity: 2 },
          { product_id: 'PROD2', sku: 'SKU2', quantity: 3 }
        ]
      )
    end

    def test_restocking_inventory
      sku_1 = create_inventory(id: 'SKU1', available: 2)
      sku_2 = create_inventory(id: 'SKU2', available: 3)

      transaction = Inventory::Transaction.from_order(
        @order.id,
        'SKU1' => 2,
        'SKU2' => 3
      )

      transaction.purchase

      cancel = CancelOrder.new(@order)
      cancel.restock

      sku_1.reload
      assert_equal(2, sku_1.available)

      sku_2.reload
      assert_equal(3, sku_2.available)
    end

    def test_refunding_payment
      @order.update_attributes!(email: 'test@workarea.com')

      profile = create_payment_profile(store_credit: 6.to_m)
      payment = create_payment(id: @order.id, profile: profile)

      payment.set_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      payment.set_store_credit
      payment.set_credit_card(
        number: '1',
        month: 1,
        year: Time.current.year + 1,
        cvv: '999',
        amount: 5.to_m
      )

      payment.adjust_tender_amounts(11.to_m)
      payment.purchase!

      Payment::Refund.new(
        payment: payment,
        amounts: { payment.store_credit.id => 3.to_m }
      ).complete!

      cancel = CancelOrder.new(@order)
      result = cancel.refund

      assert_equal(2, Payment::Refund.count)

      assert_equal(
        Money.mongoize(3.to_m),
        result.amounts[payment.store_credit.id.to_s]
      )

      assert_equal(
        Money.mongoize(5.to_m),
        result.amounts[payment.credit_card.id.to_s]
      )
    end

    def test_canceling_fulfillment
      @order.save!(validate: false)
      CreateFulfillment.new(@order).perform

      cancel = CancelOrder.new(@order)
      cancel.update_fulfillment

      fulfillment = Fulfillment.find(@order.id)
      assert_equal(:canceled, fulfillment.status)
    end

    def test_marking_the_order_canceled
      complete_checkout(@order)

      SaveOrderMetrics.perform(@order)

      assert_equal(1, Metrics::User.first.orders)

      product_metric = Metrics::ProductByDay.by_product('PROD1').first
      assert_equal(2, product_metric.units_sold)

      travel_to 1.week.from_now

      cancel = CancelOrder.new(@order)
      cancel.perform

      @order.reload
      assert(@order.canceled?)

      assert_equal(1, Metrics::User.first.cancellations)

      product_metric.reload
      assert_equal(2, product_metric.units_sold)
      assert_equal(0, product_metric.units_canceled)

      product_metric = Metrics::ProductByDay.by_product('PROD1').last
      assert_equal(0, product_metric.units_sold)
      assert_equal(2, product_metric.units_canceled)
    end
  end
end
