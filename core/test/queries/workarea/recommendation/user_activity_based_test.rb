require 'test_helper'

module Workarea
  module Recommendation
    class UserActivityBasedTest < IntegrationTest
      setup :create_products

      def create_products
        @one = create_product(id: '1')
        @two = create_product(id: '2')
        @three = create_product(id: '3')

        create_top_products(
          results: [
            { 'product_id' => '1' },
            { 'product_id' => '2' },
            { 'product_id' => '3' }
          ]
        )
      end

      def test_using_popular_products_if_blank
        activity = UserActivity.new
        query = UserActivityBased.new(activity)
        assert_equal(%w(1 2 3), query.results)
      end

      def test_using_related_products
        activity = UserActivity.new(product_ids: %w(1))
        query = UserActivityBased.new(activity)
        assert_equal(2, query.results.size)
        assert_includes(query.results, '2')
        assert_includes(query.results, '3')
      end
    end
  end
end
