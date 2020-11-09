require 'test_helper'

module Workarea
  module Storefront
    class CartItemsIntegrationTest < Workarea::IntegrationTest
      include CatalogCustomizationTestClass

      setup :set_inventory
      setup :set_product

      def set_inventory
        @inventory = create_inventory(
          id: 'SKU1',
          policy: 'standard',
          available: 2
        )
      end

      def set_product
        @product = create_product(
          name: 'Integration Product',
          variants: [
            { sku: 'SKU1', regular: 5.to_m },
            { sku: 'SKU2', regular: 6.to_m }
          ]
        )
      end

      def order
        Order.first
      end

      def test_can_add_an_item
        post storefront.cart_items_path,
          params: {
            product_id: @product.id,
            sku: @product.skus.first,
            quantity: 1
          }

        assert(response.ok?)

        order.reload
        assert_equal(@product.id, order.items.first.product_id)
        assert_equal(@product.skus.first, order.items.first.sku)
        assert_equal(1, order.items.first.quantity)
        assert_equal(5.to_m, order.items.first.total_price)
      end

      def test_fail_to_add_an_item
        post storefront.cart_items_path,
          params: {
            product_id: @product.id,
            sku: 'SKU1',
            quantity: -1
          }

        assert_response(:success)
        assert_empty(Order.all)
      end

      def test_adding_product_with_shared_skus
        product_2 = Catalog::Product.create!(name: 'Product', variants: [{ sku: 'SKU1' }])

        post storefront.cart_items_path,
          params: {
          product_id: product_2.id,
            sku: 'SKU1',
            quantity: 1
          }

        assert(response.ok?)

        order.reload
        assert_equal(product_2.id, order.items.first.product_id)
        assert_equal('SKU1', order.items.first.sku)
        assert_equal(1, order.items.first.quantity)
        assert_equal(5.to_m, order.items.first.total_price)
      end

      def test_via_tracking
        post storefront.cart_items_path,
          params: {
            product_id: @product.id,
            sku: @product.skus.first,
            quantity: 1,
            via: 'foo'
          }

        order.reload
        assert_equal('foo', order.items.first.via)

        post storefront.cart_items_path,
          params: {
            product_id: @product.id,
            sku: @product.skus.first,
            quantity: 1,
            via: 'bar'
          }

        order.reload
        assert_equal(2, order.items.first.quantity)
        assert_equal('foo', order.items.first.via)
      end

      def test_adjusts_inventory_if_not_enough_present_when_adding
        3.times do
          post storefront.cart_items_path,
            params: {
              product_id: @product.id,
              sku: @product.skus.first,
              quantity: 1
            }
        end

        order.reload
        assert_equal(@product.id, order.items.first.product_id)
        assert_equal(@product.skus.first, order.items.first.sku)
        assert_equal(2, order.items.first.quantity)
      end

      def test_does_not_add_if_there_is_no_available_inventory
        @inventory.update_attributes(available: 0)

        post storefront.cart_items_path,
          params: {
            product_id: @product.id,
            sku: @product.skus.first,
            quantity: 1
          }

        assert(response.ok?)

        order.reload
        assert_equal(0, order.quantity)
      end

      def test_does_not_add_if_there_are_invalid_customizations
        @product.update_attributes(customizations: 'foo_cust')

        post storefront.cart_items_path,
          params: {
            product_id: @product.id,
            sku: @product.skus.first,
            quantity: 1,
            foo: 'bar'
          }

        assert_redirected_to(storefront.product_path(@product))
        assert(flash[:error].present?)
        assert(order.blank?)
      end

      def test_can_update_an_item
        post storefront.cart_items_path,
          params: {
            product_id: @product.id,
            sku: @product.skus.first,
            quantity: 1
          }

        patch storefront.cart_item_path(order.items.first),
          params: { sku: 'SKU2', quantity: 2 }

        assert_redirected_to(storefront.cart_path)
        assert(flash[:success].present?)

        order.reload
        assert_equal('SKU2', order.items.first.sku)
        assert_equal(2, order.items.first.quantity)
      end

      def test_does_not_update_if_there_are_invalid_customizations
        post storefront.cart_items_path,
          params: {
            product_id: @product.id,
            sku: @product.skus.first,
            quantity: 1
          }

        @product.update_attributes(customizations: 'foo_cust')

        patch storefront.cart_item_path(order.items.first),
          params: { sku: 'SKU2', quantity: 2, foo: 'Test' }

        assert_redirected_to(storefront.product_path(@product))
        assert(flash[:error].present?)
      end

      def test_adds_customizations_to_item
        @product.update_attributes(customizations: 'foo_cust')

        post storefront.cart_items_path,
          params: {
            product_id: @product.id,
            sku: @product.skus.first,
            quantity: 1,
            foo: 'Test',
            bar: 'This'
          }

        order.reload
        assert_equal(
          { 'foo' => 'Test', 'bar' => 'This' },
          order.items.first.customizations
        )
      end

      def test_adjusts_inventory_if_not_enough_present_when_modifying
        post storefront.cart_items_path,
          params: {
            product_id: @product.id,
            sku: @product.skus.first,
            quantity: 1
          }

        patch storefront.cart_item_path(order.items.first),
          params: { quantity: 4 }

        assert_redirected_to(storefront.cart_path)

        order.reload
        assert_equal(2, order.items.first.quantity)
      end

      def test_removes_the_item_if_changing_quantity_and_no_inventory
        post storefront.cart_items_path,
          params: {
            product_id: @product.id,
            sku: @product.skus.first,
            quantity: 1
          }

        @inventory.update_attributes(available: 0)

        patch storefront.cart_item_path(order.items.first),
          params: { quantity: 4 }

        assert_redirected_to(storefront.cart_path)

        order.reload
        assert_equal(0, order.quantity)
      end

      def test_can_remove_a_cart_item
        post storefront.cart_items_path,
          params: {
            product_id: @product.id,
            sku: @product.skus.first,
            quantity: 1
          }

        order.reload
        assert_equal(1, order.quantity)

        delete storefront.cart_item_path(order.items.first)
        assert_redirected_to(storefront.cart_path)
        assert(flash[:success].present?)

        order.reload
        assert_equal(0, order.quantity)
      end

      def test_cannot_modify_items_when_override_adjusts_pricing
        post storefront.cart_items_path,
             params: {
               product_id: @product.id,
               sku: @product.skus.first,
               quantity: 1
             }

        override = Pricing::Override.find_or_create_by(id: order.id)
        override.update(subtotal_adjustment: -1.to_m)

        post storefront.cart_items_path,
          params: {
            product_id: @product.id,
            sku: @product.skus.first,
            quantity: 1
          }

        order.reload
        assert_redirected_to storefront.cart_path
        assert_equal(flash[:error], t('workarea.storefront.flash_messages.order_custom_pricing'))
        assert_equal(1, order.items.first.quantity)

        patch storefront.cart_item_path(order.items.first),
              params: { sku: 'SKU2', quantity: 2 }

        order.reload
        assert_redirected_to storefront.cart_path
        assert_equal(flash[:error], t('workarea.storefront.flash_messages.order_custom_pricing'))
        assert_equal('SKU1', order.items.first.sku)
        assert_equal(1, order.items.first.quantity)

        delete storefront.cart_item_path(order.items.first)

        order.reload
        assert_redirected_to storefront.cart_path
        assert_equal(flash[:error], t('workarea.storefront.flash_messages.order_custom_pricing'))
        assert_equal(1, order.items.first.quantity)
      end

      def test_can_modify_items_with_override_pricing_as_admin
        admin = create_user(admin: true)
        set_current_user(admin)

        post storefront.cart_items_path,
             params: {
               product_id: @product.id,
               sku: @product.skus.first,
               quantity: 1
             }

        override = Pricing::Override.find_or_create_by(id: order.id)
        override.update(subtotal_adjustment: -1.to_m)

        post storefront.cart_items_path,
          params: {
            product_id: @product.id,
            sku: @product.skus.first,
            quantity: 1
          }

        order.reload
        assert_equal(2, order.items.first.quantity)

        patch storefront.cart_item_path(order.items.first),
              params: { sku: 'SKU2', quantity: 2 }

        order.reload
        assert_equal('SKU2', order.items.first.sku)
        assert_equal(2, order.items.first.quantity)

        delete storefront.cart_item_path(order.items.first)

        order.reload
        assert_equal(0, order.quantity)
      end
    end
  end
end
