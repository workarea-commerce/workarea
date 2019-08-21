require 'test_helper'

module Workarea
  module Insights
    class StarProductsTest < TestCase
      def test_generate_weekly!
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

        StarProducts.generate_weekly!
        assert_equal(1, StarProducts.count)

        star_products = StarProducts.first
        assert_equal(1, star_products.results.size)
        assert_equal('foo', star_products.results.first['product_id'])
        assert_equal(0.1, star_products.results.first['conversion_rate'])
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

        assert_in_delta(0.15, StarProducts.avg_conversion_rate_of_top_two_views_deciles)
      end
    end
  end
end
