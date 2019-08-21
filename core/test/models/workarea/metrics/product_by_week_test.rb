require 'test_helper'

module Workarea
  module Metrics
    class ProductByWeekTest < TestCase
      def test_last_week
        two_weeks_ago = create_product_by_week(reporting_on: Time.zone.local(2018, 11, 25))
        last_week = create_product_by_week(reporting_on: Time.zone.local(2018, 12, 2))
        this_week = create_product_by_week(reporting_on: Time.zone.local(2018, 12, 5))

        travel_to Time.zone.local(2018, 12, 5)
        refute(ProductByWeek.last_week.include?(two_weeks_ago))
        assert(ProductByWeek.last_week.include?(last_week))
        refute(ProductByWeek.last_week.include?(this_week))
      end

      def test_by_views_percentile
        first = create_product_by_week(views_percentile: 100)
        second = create_product_by_week(views_percentile: 90)
        third = create_product_by_week(views_percentile: 80)
        fourth = create_product_by_week(views_percentile: 70)

        assert_equal([first], ProductByWeek.by_views_percentile(100))
        assert_equal([second], ProductByWeek.by_views_percentile(90))
        assert_equal([second, first], ProductByWeek.by_views_percentile(81..100))
        assert_equal([third, second], ProductByWeek.by_views_percentile(71..90))
        assert_equal([fourth, third, second], ProductByWeek.by_views_percentile(61..90))
      end

      def test_improved_revenue
        create_product_by_week(revenue_change: -1)
        create_product_by_week(revenue_change: 0)
        create_product_by_week(revenue_change: 1)
        create_product_by_week(revenue_change: nil)

        assert_equal(1, ProductByWeek.improved_revenue.count)
        assert_equal(1, ProductByWeek.improved_revenue.first.revenue_change)
      end

      def test_declined_revenue
        create_product_by_week(revenue_change: -1)
        create_product_by_week(revenue_change: 0)
        create_product_by_week(revenue_change: 1)
        create_product_by_week(revenue_change: nil)

        assert_equal(1, ProductByWeek.declined_revenue.count)
        assert_equal(-1, ProductByWeek.declined_revenue.first.revenue_change)
      end

      def test_append_last_week!
        Workarea.config.insights_aggregation_per_page = 1

        ProductForLastWeek.create!(product_id: 'foo', orders: 1)
        ProductByWeek.append_last_week!
        assert_equal(1, ProductByWeek.count)

        product = ProductByWeek.find_by(product_id: 'foo')
        assert_equal('foo', product.product_id)
        assert_equal(1, product.orders)

        ProductForLastWeek.delete_all
        ProductForLastWeek.create!(product_id: 'foo', orders: 1)
        ProductForLastWeek.create!(product_id: 'bar', orders: 2)
        ProductByWeek.append_last_week!
        assert_equal(3, ProductByWeek.count)

        foo = ProductByWeek.find_by(product_id: 'foo')
        assert_equal('foo', foo.product_id)
        assert_equal(1, foo.orders)

        bar = ProductByWeek.find_by(product_id: 'bar')
        assert_equal('bar', bar.product_id)
        assert_equal(2, bar.orders)
      end

      def test_revenue_change_median
        create_product_by_week(revenue_change: 1)
        create_product_by_week(revenue_change: 2)
        create_product_by_week(revenue_change: 3)
        assert_equal(2, ProductByWeek.revenue_change_median)

        create_product_by_week(revenue_change: 4)
        assert_equal(3, ProductByWeek.revenue_change_median)

        create_product_by_week(revenue_change: 5)
        assert_equal(3, ProductByWeek.revenue_change_median)

        create_product_by_week(revenue_change: 6)
        assert_equal(4, ProductByWeek.revenue_change_median)
      end

      def test_score
        two_weeks_ago = create_product_by_week(
          orders: 1,
          reporting_on: Time.zone.local(2018, 11, 25)
        )

        last_week = create_product_by_week(
          orders: 2,
          reporting_on: Time.zone.local(2018, 12, 2)
        )

        this_week = create_product_by_week(
          orders: 3,
          reporting_on: Time.zone.local(2018, 12, 5)
        )

        travel_to Time.zone.local(2018, 12, 5)

        Workarea.config.score_decay = 0.5

        assert_equal(3, this_week.score(:orders))
        assert_equal(1, last_week.score(:orders))
        assert_equal(0.25, two_weeks_ago.score(:orders))
      end

      def test_weeks_ago
        model = create_product_by_week(reporting_on: Time.zone.local(2019, 1, 25))

        travel_to Time.zone.local(2019, 1, 25)
        assert_equal(0, model.weeks_ago)

        travel_to Time.zone.local(2019, 1, 27)
        assert_equal(0, model.weeks_ago)

        travel_to Time.zone.local(2019, 2, 8)
        assert_equal(2, model.weeks_ago)

        travel_to Time.zone.local(2019, 2, 9)
        assert_equal(2, model.weeks_ago)

        travel_to Time.zone.local(2019, 2, 11)
        assert_equal(3, model.weeks_ago)
      end
    end
  end
end
