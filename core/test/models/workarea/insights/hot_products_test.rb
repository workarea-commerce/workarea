require 'test_helper'

module Workarea
  module Insights
    class HotProductsTest < TestCase
      def test_results
        create_product_by_week(
          product_id: 'foo',
          revenue_change: 1,
          reporting_on: Time.current.last_week
        )
        create_product_by_week(
          product_id: 'bar',
          revenue_change: 4,
          reporting_on: Time.current.last_week
        )
        create_product_by_week(
          product_id: 'baz',
          revenue_change: 2,
          reporting_on: Time.current.last_week
        )
        create_product_by_week(
          product_id: 'qoo',
          revenue_change: 5,
          reporting_on: Time.current.last_week
        )
        create_product_by_week(
          product_id: 'quz',
          revenue_change: 15,
          reporting_on: Time.current.last_week
        )
        create_product_by_week(
          product_id: 'qux',
          revenue_change: 0,
          reporting_on: Time.current.last_week
        )

        HotProducts.generate_weekly!
        assert_equal(1, HotProducts.count)

        hot_products = HotProducts.first
        assert_equal(1, hot_products.results.size)
        assert_equal('quz', hot_products.results.first['product_id'])
        assert_equal(15, hot_products.results.first['revenue_change'])
      end

      def test_falling_back_to_fewer_deviations
        create_product_by_week(
          product_id: 'foo',
          revenue_change: 1,
          reporting_on: Time.current.last_week
        )
        create_product_by_week(
          product_id: 'bar',
          revenue_change: 4,
          reporting_on: Time.current.last_week
        )
        create_product_by_week(
          product_id: 'baz',
          revenue_change: 2,
          reporting_on: Time.current.last_week
        )
        create_product_by_week(
          product_id: 'qoo',
          revenue_change: 5,
          reporting_on: Time.current.last_week
        )
        create_product_by_week(
          product_id: 'qux',
          revenue_change: 0,
          reporting_on: Time.current.last_week
        )

        HotProducts.generate_weekly!
        assert_equal(1, HotProducts.count)

        hot_products = HotProducts.first
        assert_equal(1, hot_products.results.size)
        assert_equal('qoo', hot_products.results.first['product_id'])
        assert_equal(5, hot_products.results.first['revenue_change'])
      end

      def test_revenue_change_median
        create_product_by_week(revenue_change: 1, reporting_on: 2.weeks.ago)
        [1, 4, 2, 5, 0, -1].each do |change|
          create_product_by_week(
            revenue_change: change,
            reporting_on: Time.current.last_week
          )
        end

        assert_equal(4, HotProducts.revenue_change_median)
      end

      def test_revenue_change_standard_deviation
        create_product_by_week(revenue_change: 1, reporting_on: 2.weeks.ago)
        [6, 2, 3, 1, 0, -1].each do |change|
          create_product_by_week(
            revenue_change: change,
            reporting_on: Time.current.last_week
          )
        end

        assert_in_delta(1.87, HotProducts.revenue_change_standard_deviation)
      end

      def test_handles_weeks_without_increased_revenue
        create_product_by_week(
          product_id: 'foo',
          revenue_change: 0,
          reporting_on: Time.current.last_week
        )
        create_product_by_week(
          product_id: 'bar',
          revenue_change: 0,
          reporting_on: Time.current.last_week
        )

        HotProducts.generate_weekly!
        assert_equal(0, HotProducts.count)
      end
    end
  end
end
