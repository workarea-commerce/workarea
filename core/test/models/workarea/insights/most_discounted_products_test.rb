require 'test_helper'

module Workarea
  module Insights
    class MostDiscountedProductsTest < TestCase
      def test_generate_weekly!
        create_product_by_week(
          product_id: 'foo',
          orders: 1,
          discount_rate: 0,
          reporting_on: Time.current.last_week
        )
        create_product_by_week(
          product_id: 'bar',
          orders: 4,
          average_discount: 0.1,
          discount_rate: 0.25,
          reporting_on: Time.current.last_week
        )
        create_product_by_week(
          product_id: 'baz',
          orders: 4,
          average_discount: 0.07,
          discount_rate: 0.25,
          reporting_on: Time.current.last_week
        )
        create_product_by_week(
          product_id: 'qoo',
          orders: 4,
          average_discount: 0.1,
          discount_rate: 0.3,
          reporting_on: 2.weeks.ago
        )

        MostDiscountedProducts.generate_weekly!
        assert_equal(1, MostDiscountedProducts.count)

        most_discounted_products = MostDiscountedProducts.first
        assert_equal(2, most_discounted_products.results.size)
        assert_equal('bar', most_discounted_products.results.first['product_id'])
        assert_equal(0.1, most_discounted_products.results.first['average_discount'])
        assert_equal('baz', most_discounted_products.results.second['product_id'])
        assert_equal(0.07, most_discounted_products.results.second['average_discount'])
      end
    end
  end
end
