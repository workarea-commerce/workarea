require 'test_helper'

module Workarea
  module Recommendation
    class ProductBasedTest < IntegrationTest
      setup :create_products

      def create_products
        @product = create_product(id: '0')
        @settings = Settings.find_or_initialize_by(id: @product.id)

        create_product(id: '1')
        create_product(id: '2')
        create_product(id: '3')
      end

      def test_falling_back_to_related_products
        query = ProductBased.new(@product)

        assert_equal(3, query.results.size)
        assert_includes(query.results, '1')
        assert_includes(query.results, '2')
        assert_includes(query.results, '3')
      end

      def test_using_custom_products
        @settings.update_attributes!(
          sources: %w(custom),
          product_ids: %w(2 3 1)
        )

        query = ProductBased.new(@product)
        assert_equal(%w(2 3 1), query.results)
      end

      def test_using_purchased_with
        Order.create!(
          placed_at: Time.current,
          items: [
            { product_id: '0', sku: 'SKU' },
            { product_id: '2', sku: 'SKU' }
          ]
        )

        2.times do
          Order.create!(
            placed_at: Time.current,
            items: [
              { product_id: '0', sku: 'SKU' },
              { product_id: '3', sku: 'SKU' }
            ]
          )
        end

        ProcessProductRecommendations.new.perform

        @settings.update_attributes!(sources: %w(purchased))
        query = ProductBased.new(@product)
        assert_equal(%w(3 2), query.results)
      end

      def test_not_including_deleted_products
        Order.create!(
          placed_at: Time.current,
          items: [
            { product_id: '0', sku: 'SKU' },
            { product_id: '2', sku: 'SKU' }
          ]
        )

        2.times do
          Order.create!(
            placed_at: Time.current,
            items: [
              { product_id: '0', sku: 'SKU' },
              { product_id: '3', sku: 'SKU' }
            ]
          )
        end

        ProcessProductRecommendations.new.perform
        @settings.update_attributes!(sources: %w(purchased))

        Catalog::Product.find('3').destroy

        query = ProductBased.new(@product)
        assert_equal(%w(2), query.results)
      end
    end
  end
end
