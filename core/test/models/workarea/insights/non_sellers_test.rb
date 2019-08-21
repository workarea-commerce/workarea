require 'test_helper'

module Workarea
  module Insights
    class NonSellersTest < TestCase
      def test_generate_weekly!
        create_product_by_week(
          product_id: 'foo',
          views: 1,
          reporting_on: Time.current.last_week
        )
        create_product_by_week(
          product_id: 'bar',
          views: 0,
          reporting_on: Time.current.last_week
        )
        create_product_by_week(
          product_id: 'baz',
          views: 2,
          orders: 1,
          reporting_on: Time.current.last_week
        )
        create_product_by_week(
          product_id: 'qoo',
          views_percentile: 100,
          reporting_on: 2.weeks.ago
        )

        NonSellers.generate_weekly!
        assert_equal(1, NonSellers.count)

        star_products = NonSellers.first
        assert_equal(1, star_products.results.size)
        assert_equal('foo', star_products.results.first['product_id'])
        assert_equal(1, star_products.results.first['views'])
      end
    end
  end
end
