require 'test_helper'

module Workarea
  class AddMultipleCartItemsTest < TestCase
    setup :products

    def products
      @products ||= [
        create_product(
          id: 'PROD1',
          variants: [{ sku: 'SKU1', regular: 5.00 }]
        ),
        create_product(
          id: 'PROD2',
          variants: [{ sku: 'SKU2', regular: 10.00 }]
        )
      ]
    end

    def test_perform
      order = create_order
      item_params = [
        { product_id: 'PROD1', sku: 'sku1', quantity: 2 },
        { sku: 'Sku2', quantity: 1 }
      ]

      add_to_cart = AddMultipleCartItems.new(order, item_params)
      assert(add_to_cart.perform)

      order.reload
      assert_equal(2, order.items.count)

      item = order.items.first
      assert_equal('PROD1', item.product_id)
      assert_equal('SKU1', item.sku)
      assert_equal(2, item.quantity)

      item = order.items.second
      assert_equal('PROD2', item.product_id)
      assert_equal('SKU2', item.sku)
      assert_equal(1, item.quantity)
    end

    def test_perform_partial_success
      order = create_order
      items_params = [
        { sku: 'sku2', quantity: 1 },
        { sku: 'SKU3', quantity: 2 }
      ]
      add_to_cart = AddMultipleCartItems.new(order, items_params)

      refute(add_to_cart.perform)
      assert(add_to_cart.items.first.valid?)
      assert(add_to_cart.items.first.persisted?)

      order.reload
      assert_equal(1, order.items.count)

      item = add_to_cart.items.first.item
      assert(item.persisted?)
      assert_equal('PROD2', item.product_id)
      assert_equal('SKU2', item.sku)
      assert_equal(1, item.quantity)

      item = add_to_cart.items.last
      refute(item.persisted?)
      refute(item.item.present?)

      assert_equal(
        t('workarea.add_multiple_cart_items.errors.missing_product'),
        item.errors.full_messages.first
      )
    end

    def test_perform!
      order = create_order
      items_params = [
        { sku: 'sku2', quantity: 1 },
        { sku: 'SKU3', quantity: 2 }
      ]
      add_to_cart = AddMultipleCartItems.new(order, items_params)

      refute(add_to_cart.perform!)

      order.reload
      assert_equal(0, order.items.count)

      items_params = [
        { sku: 'sku1', quantity: 2 },
        { sku: 'SKU2', quantity: 1 }
      ]
      add_to_cart = AddMultipleCartItems.new(order, items_params)

      assert(add_to_cart.perform!)

      order.reload
      assert_equal(2, order.items.count)
    end
  end
end
