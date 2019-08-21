require 'test_helper'

module Workarea
  module Recommendation
    class OrderBasedTest < IntegrationTest
      setup :create_products

      def create_products
        create_product(id: '1')
        create_product(id: '2')
        create_product(id: '3')
      end

      def test_results
        create_product(id: '4')

        Order.create!(
          placed_at: Time.current,
          items: [
            { product_id: '1', sku: 'SKU' },
            { product_id: '2', sku: 'SKU' }
          ]
        )

        2.times do
          Order.create!(
            placed_at: Time.current,
            items: [
              { product_id: '1', sku: 'SKU' },
              { product_id: '3', sku: 'SKU' }
            ]
          )
        end

        ProcessProductRecommendations.new.perform

        order = Order.new(items: [{ product_id: '1' }])
        assert_equal(%w(3 2 4), OrderBased.new(order).results)
      end

      def test_falling_back_to_related_products
        order = Order.new(items: [{ product_id: '1' }])
        query = OrderBased.new(order)

        assert_equal(2, query.results.size)
        assert_includes(query.results, '2')
        assert_includes(query.results, '3')
      end
    end
  end
end
