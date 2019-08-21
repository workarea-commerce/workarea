require 'test_helper'

module Workarea
  module Storefront
    class RecommendationsSystemTest < Workarea::SystemTest
      setup :set_product
      setup :set_recommendation

      def set_product
        @product = create_product(
          name: 'Integration Product',
          variants: [
            { name: 'SKU1', sku: 'SKU1', regular: 5.to_m },
            { name: 'SKU2', sku: 'SKU2', regular: 6.to_m }
          ]
        )
      end

      def set_recommendation
        @recommendation = create_product(
          name: 'Recommendation Product',
          variants: [{ sku: 'SKU3', regular: 5.to_m }]
        )

        create_inventory(id: 'SKU1', policy: 'standard', available: 2)
        create_inventory(id: 'SKU2', policy: 'standard', available: 2)
        create_inventory(id: 'SKU3', policy: 'standard', available: 2)

        create_recommendations(
          id: @product.id,
          product_ids: [@recommendation.id]
        )
      end

      def test_showing_recommendations_on_a_product
        visit storefront.product_path(@product)
        assert(page.has_content?('Recommendation Product'))
      end

      def test_showing_recommendations_on_a_cart
        visit storefront.product_path(@product)
        select @product.skus.first, from: 'sku'
        click_button t('workarea.storefront.products.add_to_cart')
        click_link t('workarea.storefront.carts.view_cart')

        visit storefront.cart_path
        assert(page.has_content?(@product.name))
        assert(page.has_content?('Recommendation Product'))
      end

      def test_showing_personalized_recommendations
        create_product(id: '1', name: 'Product One')
        create_product(id: '2', name: 'Product Two')
        create_top_products(
          results: [
            { 'product_id' => '1' },
            { 'product_id' => '2' }
          ]
        )

        visit storefront.recommendations_path

        assert(page.has_content?('Product One'))
        assert(page.has_content?('Product Two'))
      end

      def test_showing_recommendations_on_user_account
        create_product(id: '1', name: 'Product One')
        create_product(id: '2', name: 'Product Two')
        create_top_products(
          results: [
            { 'product_id' => '1' },
            { 'product_id' => '2' }
          ]
        )

        set_current_user(create_user)
        visit storefront.users_account_path

        assert(page.has_content?('Product One'))
        assert(page.has_content?('Product Two'))
      end
    end
  end
end
