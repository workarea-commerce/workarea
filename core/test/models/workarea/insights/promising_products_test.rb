require 'test_helper'

module Workarea
  module Insights
    class PromisingProductsTest < TestCase
      def test_results
        create_product_by_week(
          product_id: 'foo',
          views_percentile: 100,
          views: 100,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.1
        )
        create_product_by_week(
          product_id: 'bar',
          views_percentile: 70,
          views: 90,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.9
        )
        create_product_by_week(
          product_id: 'baz',
          views_percentile: 60,
          views: 80,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.01
        )
        create_product_by_week(
          product_id: 'qux',
          views_percentile: 50,
          views: 10,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.9
        )

        PromisingProducts.generate_weekly!
        assert_equal(1, PromisingProducts.count)

        promising_products = PromisingProducts.first
        assert_equal(1, promising_products.results.size)
        assert_equal('bar', promising_products.results.first['product_id'])
        assert_equal(0.9, promising_products.results.first['conversion_rate'])
      end

      def test_falling_back_to_second_pass
        create_product_by_week(
          product_id: 'foo',
          views_percentile: 100,
          views: 20,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.1
        )
        create_product_by_week(
          product_id: 'bar',
          views_percentile: 70,
          views: 15,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.9
        )
        create_product_by_week(
          product_id: 'baz',
          views_percentile: 60,
          views: 10,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.01
        )
        create_product_by_week(
          product_id: 'qux',
          views_percentile: 50,
          views: 5,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.9
        )

        PromisingProducts.generate_weekly!

        assert_empty(PromisingProducts.first_pass)
        assert_equal(1, PromisingProducts.count)

        promising_products = PromisingProducts.first
        assert_equal(1, promising_products.results.size)
        assert_equal('bar', promising_products.results.first['product_id'])
        assert_equal(0.9, promising_products.results.first['conversion_rate'])
      end

      def test_avg_conversion_rate_of_bottom_seven_views_deciles
        create_product_by_week(
          views_percentile: 100,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.1
        )
        create_product_by_week(
          views_percentile: 70,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.2
        )
        create_product_by_week(
          views_percentile: 60,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.3
        )
        create_product_by_week(
          views_percentile: 50,
          reporting_on: 2.weeks.ago,
          conversion_rate: 0.4
        )

        assert_in_delta(0.25, PromisingProducts.avg_conversion_rate_of_bottom_seven_views_deciles)
      end

      def test_avg_views_of_bottom_seven_views_deciles
        create_product_by_week(
          views_percentile: 100,
          views: 100,
          reporting_on: Time.current.last_week,
        )
        create_product_by_week(
          views_percentile: 70,
          views: 60,
          reporting_on: Time.current.last_week,
        )
        create_product_by_week(
          views_percentile: 60,
          views: 50,
          reporting_on: Time.current.last_week,
        )
        create_product_by_week(
          views_percentile: 50,
          views: 40,
          reporting_on: 2.weeks.ago,
        )

        assert_in_delta(55, PromisingProducts.avg_views_of_bottom_seven_views_deciles)
      end
    end
  end
end
