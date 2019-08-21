require 'test_helper'

module Workarea
  module Insights
    class ProductsPurchasedTogetherTest < TestCase
      def test_results
        create_product_by_week(
          product_id: 'foo',
          revenue: 100,
          reporting_on: Time.current.last_week
        )
        create_product_by_week(
          product_id: 'bar',
          revenue: 90,
          reporting_on: Time.current.last_week
        )
        create_product_by_week(
          product_id: 'baz',
          revenue: 80,
          reporting_on: Time.current.last_week
        )
        create_product_by_week(
          product_id: 'qoo',
          revenue: 70,
          reporting_on: Time.current.last_week
        )
        create_product_by_week(
          product_id: 'quz',
          revenue: 60,
          reporting_on: Time.current.last_week
        )
        create_product_by_week(
          product_id: 'qux',
          revenue: 50,
          reporting_on: Time.current.last_week
        )

        predictor = Recommendation::ProductPredictor.new
        2.times { predictor.orders.add_set(Order.new.id, %w(foo bar)) }
        predictor.orders.add_set(Order.new.id, %w(foo baz))
        predictor.process!

        ProductsPurchasedTogether.generate_weekly!
        assert_equal(1, ProductsPurchasedTogether.count)

        products_purchased_together = ProductsPurchasedTogether.first
        assert_equal(3, products_purchased_together.results.size)

        assert_equal('foo', products_purchased_together.results.first['product_id'])
        assert_equal(100, products_purchased_together.results.first['revenue'])
        assert_equal('bar', products_purchased_together.results.first['related_product_id'])

        assert_equal('bar', products_purchased_together.results.second['product_id'])
        assert_equal(90, products_purchased_together.results.second['revenue'])
        assert_equal('foo', products_purchased_together.results.second['related_product_id'])

        assert_equal('baz', products_purchased_together.results.third['product_id'])
        assert_equal(80, products_purchased_together.results.third['revenue'])
        assert_equal('foo', products_purchased_together.results.third['related_product_id'])
      end
    end
  end
end
