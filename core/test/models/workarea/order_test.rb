require 'test_helper'

module Workarea
  class OrderTest < TestCase
    def test_quantity
      order = Order.new

      assert_equal(0, order.quantity)
      assert(order.no_items?)

      order.items.build(product_id: 'PROD', sku: 'SKU1', quantity: 1)
      assert_equal(1, order.quantity)

      order.items.build(product_id: 'PROD', sku: 'SKU2', quantity: 2)
      assert_equal(3, order.quantity)

      order.items.build(quantity: 2)
      assert_equal(3, order.quantity)
    end

    def test_purchasable?
      order = Order.new
      refute(order.purchasable?)

      order.email = 'test@workarea.com'
      refute(order.purchasable?)

      order.items.build(product_id: '1', sku: 'SKU1', quantity: 1)
      assert(order.purchasable?)
    end

    def test_place
      order = Order.new(email: 'test@workarea.com')
      order.place

      refute(order.placed?)

      order.items.build(product_id: 'PROD', sku: 'SKU1')
      order.place

      assert(order.placed?)
    end

    def test_cancel
      order = Order.new
      order.cancel
      assert(order.canceled?)
    end

    def test_status
      order = Order.new(email: 'test@workarea.com', created_at: Time.current)
      order.items.build(product_id: 'PROD', sku: 'SKU1')

      assert_equal(:cart, order.status)

      order.checkout_started_at = Time.current
      assert_equal(:checkout, order.status)

      order.fraud_suspected_at = Time.current
      assert_equal(:suspected_fraud, order.status)

      order.place
      assert_equal(:placed, order.status)

      order.cancel
      assert_equal(:canceled, order.status)

      order = Order.new(created_at: Time.current - 1.day)
      assert_equal(:abandoned, order.status)
    end

    def test_add_item
      order = Order.new(email: 'test@workarea.com')

      assert_difference('order.quantity', 2) do
        order.add_item(product_id: '1234', sku: 'SKU', quantity: 2)
      end

      assert_equal('1234', order.items.last.product_id)
      assert_equal('SKU', order.items.last.sku)
      assert_equal(2, order.items.last.quantity)
      assert(order.items.last.created_at.present?)
      assert(order.items.last.updated_at.present?)

      order.add_item(product_id: '1234', sku: 'SKU', quantity: 2)
      assert_equal(1, order.items.count)
      assert_equal(4, order.items.last.quantity)

      assert_no_changes 'order.items.count' do
        order.add_item(
          product_id: '1234',
          sku: 'SKU',
          quantity: 1
        )
      end

      Workarea.config.distinct_order_item_attributes << :discountable

      assert_changes 'order.items.count' do
        order.add_item(
          product_id: '1234',
          sku: 'SKU',
          quantity: 1,
          discountable: false
        )
      end

      assert_no_changes 'order.items.count' do
        order.add_item(
          product_id: '1234',
          sku: 'SKU',
          quantity: 1,
          discountable: true
        )
      end
    end

    def test_update_item
      order = Order.new
      item = order.items.build(product_id: '1234', sku: 'SKU', quantity: 2)

      order.update_item(item.id, quantity: 1)
      assert_equal(1, order.items.first.quantity)

      order.update_item(item.id, sku: 'SKU2')
      assert_equal(1, order.items.count)
      assert_equal('SKU2', order.items.first.sku)

      order = Order.new
      item_one = order.items.build(product_id: '1234', sku: 'SKU1', quantity: 2)
      item_two = order.items.build(product_id: '1234', sku: 'SKU2', quantity: 1)

      assert_equal(2, order.items.length)
      assert(order.has_sku?('SKU2'))
      assert_equal(2, item_one.quantity)

      order.update_item(item_two.id, sku: 'SKU1')

      assert_equal(1, order.items.length)
      assert_equal(3, item_one.quantity)
    end

    def test_remove_item
      order = Order.new
      item = order.items.build(product_id: '1234', sku: 'SKU', quantity: 2)

      order.remove_item(item.id)
      assert(0, order.quantity)
      assert(order.items.empty?)
    end

    def test_add_promo_code
      order = Order.new

      order.add_promo_code('PROMOCODE1234')
      assert_includes(order.promo_codes, 'PROMOCODE1234')

      order.add_promo_code('PROMOCODE1234')
      assert_equal(1, order.promo_codes.count { |c| c == 'PROMOCODE1234' })

      order.add_promo_code('pRoMoCoDe1234')
      assert_equal(1, order.promo_codes.length)
      assert_equal('PROMOCODE1234', order.promo_codes.first)
    end

    def test_items_find_existing
      order = Order.new

      item = order.items.build(sku: 'sku')
      assert_equal(item, order.items.find_existing('sku'))

      item.customizations = { 'email' => 'bcrouse@workarea.com' }
      assert(order.items.find_existing('sku').blank?)
      assert_equal(
        item,
        order.items.find_existing(
          'sku',
          customizations: { 'email' => 'bcrouse@workarea.com' }
        )
      )
    end

    def test_name
      order = Order.new
      assert_equal("Order #{order.id}", order.name)
    end

    def test_fraud_suspected?
      order = Order.new
      order.fraud_decision = create_fraud_decision

      refute(order.fraud_suspected?)

      order.fraud_decision = create_fraud_decision(decision: :declined)
      order.fraud_suspected_at = Time.current
      assert(order.fraud_suspected?)
    end

    def test_set_fraud_decision
      order = Order.new
      order.set_fraud_decision!(create_fraud_decision)

      refute(order.fraud_suspected_at.present?)
      assert(order.fraud_decided_at.present?)

      order.set_fraud_decision!(create_fraud_decision(decision: :declined))
      assert(order.fraud_suspected_at.present?)
    end

    def test_item_count_limit
      Workarea.config.item_count_limit = 2

      order = Order.new(email: 'test@workarea.com')

      order.items.build(sku: 'SKU1', product_id: 'PROD')
      assert(order.valid?)

      order.items.build(sku: 'SKU2', product_id: 'PROD', quantity: 2)
      assert(order.valid?)

      order.items.build(sku: 'SKU3', product_id: 'PROD')
      refute(order.valid?)
      assert_equal(
        t('workarea.order.errors.count_limit', size: 2),
        order.errors.full_messages.first
      )
    end
  end
end
