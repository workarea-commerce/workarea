require 'test_helper'

module Workarea
  module Storefront
    class CartSystemTest < Workarea::SystemTest
      setup :set_inventory
      setup :set_product

      def set_inventory
        create_inventory(id: 'SKU1', policy: 'standard', available: 2)
      end

      def set_product
        @product = create_product(
          name: 'Integration Product',
          variants: [
            { name: 'SKU1', sku: 'SKU1', regular: 5.to_m },
            { name: 'SKU2', sku: 'SKU2', regular: 6.to_m }
          ]
        )
      end

      def test_showing_an_empty_cart
        visit storefront.cart_path
        assert(page.has_content?(t('workarea.storefront.carts.empty')))
      end

      def test_showing_a_cart_with_free_items
        create_product(
          name: 'Free Item',
          variants: [{ sku: 'FREE_SKU', regular: 5.to_m }]
        )

        create_free_gift_discount(
          name: 'Test',
          sku: 'FREE_SKU',
          order_total_operator: :greater_than,
          order_total: 1
        )

        visit storefront.product_path(@product)
        select @product.skus.first, from: 'sku'
        click_button t('workarea.storefront.products.add_to_cart')
        click_link t('workarea.storefront.carts.view_cart')

        assert(page.has_content?('Integration Product'))
        assert(page.has_content?('Free Item'))
        assert(page.has_content?('5.00'))
      end

      def test_managing_cart_items
        visit storefront.product_path(@product)
        select @product.skus.first, from: 'sku'
        click_button t('workarea.storefront.products.add_to_cart')

        assert(page.has_content?('Success'))
        assert(page.has_content?(@product.name))

        within '.ui-dialog' do
          fill_in 'quantity', with: 2
        end

        assert(page.has_content?('Success'))
        assert(page.has_content?(@product.name))

        click_button t('workarea.storefront.carts.remove')
        assert(page.has_content?('Success'))
        assert(page.has_content?(t('workarea.storefront.carts.empty')))
      end

      def test_resuming_an_order_from_reminder
        visit storefront.product_path(@product)
        select @product.skus.first, from: 'sku'
        click_button t('workarea.storefront.products.add_to_cart')
        within '.ui-dialog' do
          assert(page.has_content?(@product.name))
        end

        order = Order.first

        Capybara.reset_sessions!

        visit storefront.cart_path
        assert(page.has_no_selector?('ul.product-list'))

        visit storefront.resume_cart_path(order.token)

        visit storefront.cart_path
        within('ul.product-list') { assert(page.has_content?(@product.name)) }
      end
    end
  end
end
