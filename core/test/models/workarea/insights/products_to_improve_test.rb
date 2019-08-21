require 'test_helper'

module Workarea
  module Insights
    class ProductsToImproveTest < TestCase
      def test_results
        create_product_by_week(
          product_id: 'foo',
          views_percentile: 100,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.1
        )
        create_product_by_week(
          product_id: 'bar',
          views_percentile: 90,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.2
        )
        create_product_by_week(
          product_id: 'baz',
          views_percentile: 100,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.01
        )
        create_product_by_week(
          product_id: 'qoo',
          views_percentile: 100,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.02
        )

        ProductsToImprove.generate_weekly!
        assert_equal(1, ProductsToImprove.count)

        products_to_improve = ProductsToImprove.first
        assert_equal(2, products_to_improve.results.size)
        assert_equal('baz', products_to_improve.results.first['product_id'])
        assert_equal(0.01, products_to_improve.results.first['conversion_rate'])
        assert_equal('qoo', products_to_improve.results.second['product_id'])
        assert_equal(0.02, products_to_improve.results.second['conversion_rate'])
      end

      def test_falling_back_to_second_pass
        create_product_by_week(
          product_id: 'foo',
          views_percentile: 90,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.1
        )
        create_product_by_week(
          product_id: 'bar',
          views_percentile: 80,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.2
        )

        ProductsToImprove.generate_weekly!

        assert_empty(ProductsToImprove.first_pass)
        assert_equal(1, ProductsToImprove.count)

        products_to_improve = ProductsToImprove.first
        assert_equal(1, products_to_improve.results.size)
        assert_equal('foo', products_to_improve.results.first['product_id'])
        assert_equal(0.1, products_to_improve.results.first['conversion_rate'])
      end

      def test_avg_conversion_rate_of_top_two_views_deciles
        create_product_by_week(
          views_percentile: 100,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.1
        )
        create_product_by_week(
          views_percentile: 90,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.2
        )
        create_product_by_week(
          views_percentile: 90,
          reporting_on: 2.weeks.ago,
          conversion_rate: 0.01
        )
        create_product_by_week(
          views_percentile: 80,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.01
        )

        assert_in_delta(0.15, ProductsToImprove.avg_conversion_rate_of_top_two_views_deciles)
      end

      def test_avg_conversion_rate_of_top_five_views_deciles
        create_product_by_week(
          views_percentile: 100,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.1
        )
        create_product_by_week(
          views_percentile: 90,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.2
        )
        create_product_by_week(
          views_percentile: 90,
          reporting_on: 2.weeks.ago,
          conversion_rate: 0.1
        )
        create_product_by_week(
          views_percentile: 80,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.1
        )
        create_product_by_week(
          views_percentile: 70,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.1
        )
        create_product_by_week(
          views_percentile: 60,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.1
        )
        create_product_by_week(
          views_percentile: 50,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.1
        )

        assert_in_delta(0.12, ProductsToImprove.avg_conversion_rate_of_top_five_views_deciles)
      end
    end
  end
end
