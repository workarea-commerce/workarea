require 'test_helper'

module Workarea
  module Storefront
    class CartItemsSystemTest < Workarea::SystemTest
      def test_adding_too_much_to_cart
        create_inventory(id: 'SKU1', policy: 'standard', available: 1)
        product = create_product(
          name: 'Integration Product',
          variants: [
            { sku: 'SKU1', regular: 10.to_m },
            { sku: 'SKU2', regular: 20.to_m }
          ]
        )

        visit storefront.product_path(product)
        select 'SKU1'
        fill_in 'Quantity', with: 2
        click_on t('workarea.storefront.products.add_to_cart')

        assert_no_text '["' + t('workarea.errors.messages.sku_limited_quantity', sku: 'SKU1', quantity: 1) + ']"'
        assert_text t('workarea.errors.messages.sku_limited_quantity', sku: 'SKU1', quantity: 1)
      end

      def test_adding_to_cart
        create_inventory(id: 'SKU1', policy: 'standard', available: 1)

        product = create_product(
          name: 'Integration Product',
          variants: [
            { sku: 'SKU1', regular: 10.to_m },
            { sku: 'SKU2', regular: 20.to_m }
          ]
        )

        visit storefront.product_path(product)

        #
        # No SKU selected
        #

        click_on t('workarea.storefront.products.add_to_cart')

        # Caught by client-side validation
        assert(page.has_content?(t('validate.required')))

        #
        # SKU selected
        #

        select 'SKU1'

        # Click nearby element to blur select menu. Needed in order to clear
        # client-side validation error
        find('h1').click

        within '.page-header__cart-count' do
          assert(page.has_content?('0'))
        end

        click_on t('workarea.storefront.products.add_to_cart')

        within '.ui-dialog' do
          assert(page.has_content?('Success'))
          assert(page.has_content?('Integration Product'))
        end

        within '.page-header__cart-count' do
          assert(page.has_content?('1'))
        end

        #
        # Adding more inventory than available
        #

        visit storefront.product_path(product)
        select 'SKU1'
        click_on t('workarea.storefront.products.add_to_cart')
        assert(page.has_content?(t('workarea.storefront.flash_messages.error')))
      end

      def test_via_tracking
        category = create_category(
          product_rules: [{ name: 'search', operator: 'equals', value: '*' }]
        )

        product = create_product(
          name: 'Category Test',
          variants: [{ sku: 'SKU1', regular: 5 }]
        )

        visit storefront.category_path(category)
        click_link 'Category Test', match: :first

        assert_current_path(storefront.product_path(product, via: category.to_gid_param))
        click_on t('workarea.storefront.products.add_to_cart')

        order = Order.desc(:created_at).first
        assert_equal(category, GlobalID.find(order.items.last.via))

        product = create_product(
          name: 'Search Test',
          variants: [{ sku: 'SKU2', regular: 5 }]
        )

        visit storefront.search_path(q: 'search')
        click_link 'Search Test', match: :first

        search = Navigation::SearchResults.new(q: 'search')
        assert_current_path(storefront.product_path(product, via: search.to_gid_param))
        click_on t('workarea.storefront.products.add_to_cart')

        assert_equal(search.id, GlobalID.find(order.reload.items.last.via).id)
      end
    end
  end
end
