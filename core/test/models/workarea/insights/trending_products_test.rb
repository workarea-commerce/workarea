require 'test_helper'

module Workarea
  module Insights
    class TrendingProductsTest < TestCase
      def test_generate_monthly!
        create_product_by_week(
          product_id: 'foo',
          revenue_change: 10,
          orders: 5,
          reporting_on: Time.zone.local(2018, 12, 3)
        )
        create_product_by_week(
          product_id: 'foo',
          revenue_change: -10,
          orders: 0,
          reporting_on: Time.zone.local(2018, 12, 10)
        )
        create_product_by_week(
          product_id: 'foo',
          revenue_change: 20,
          orders: 10,
          reporting_on: Time.zone.local(2018, 12, 17)
        )
        create_product_by_week(
          product_id: 'bar',
          revenue_change: 10,
          orders: 5,
          reporting_on: Time.zone.local(2018, 12, 3)
        )
        create_product_by_week(
          product_id: 'bar',
          revenue_change: -10,
          orders: 0,
          reporting_on: Time.zone.local(2018, 12, 10)
        )
        create_product_by_week(
          product_id: 'bar',
          revenue_change: 0,
          orders: 0,
          reporting_on: Time.zone.local(2018, 12, 17)
        )
        create_product_by_week(
          product_id: 'baz',
          revenue_change: 10,
          orders: 5,
          reporting_on: Time.zone.local(2018, 12, 3)
        )
        create_product_by_week(
          product_id: 'baz',
          revenue_change: -10,
          orders: 1,
          reporting_on: Time.zone.local(2018, 12, 10)
        )
        create_product_by_week(
          product_id: 'baz',
          revenue_change: 0,
          orders: 0,
          reporting_on: Time.zone.local(2018, 12, 17)
        )

        travel_to Time.zone.local(2019, 1, 17)
        TrendingProducts.generate_monthly!
        assert_equal(1, TrendingProducts.count)

        trending_products = TrendingProducts.first
        assert_equal(3, trending_products.results.size)

        assert_equal('foo', trending_products.results.first['product_id'])
        assert_equal(2, trending_products.results.first['improving_weeks'])
        assert_equal(15, trending_products.results.first['orders'])

        assert_equal('baz', trending_products.results.second['product_id'])
        assert_equal(1, trending_products.results.second['improving_weeks'])
        assert_equal(6, trending_products.results.second['orders'])

        assert_equal('bar', trending_products.results.third['product_id'])
        assert_equal(1, trending_products.results.third['improving_weeks'])
        assert_equal(5, trending_products.results.third['orders'])
      end
    end
  end
end
