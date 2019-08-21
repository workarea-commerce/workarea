require 'test_helper'

module Workarea
  class GenerateInsightsTest < TestCase
    def test_perform_resets_and_appends_last_weeks_aggregation
      travel_to Time.zone.local(2018, 10, 27)

      Metrics::ProductForLastWeek.create!(product_id: 'foo')
      Metrics::ProductForLastWeek.create!(product_id: 'bar')
      Metrics::ProductByDay.inc(key: { product_id: 'foo' }, views: 10)
      Metrics::ProductByDay.inc(key: { product_id: 'bar' }, views: 20)

      travel_to Time.zone.local(2018, 10, 29)
      GenerateInsights.new.perform

      assert_equal(2, Metrics::ProductByWeek.count)
      assert_equal(10, Metrics::ProductForLastWeek.find_by(product_id: 'foo').views)
      assert_equal(20, Metrics::ProductForLastWeek.find_by(product_id: 'bar').views)
    end

    def test_generates_weekly_insights_on_monday
      travel_to Time.zone.local(2018, 10, 27)
      Metrics::ProductByDay.inc(key: { product_id: 'foo' }, views: 10, orders: 10)
      Metrics::ProductByDay.inc(key: { product_id: 'bar' }, views: 15, orders: 5)
      Metrics::ProductByDay.inc(key: { product_id: 'baz' }, views: 20, orders: 1)

      travel_to Time.zone.local(2018, 10, 29)
      GenerateInsights.new.perform

      assert_equal(1, Insights::ProductsToImprove.count)
      assert_equal(1, Insights::ProductsToImprove.first.results.size)

      travel_to Time.zone.local(2018, 10, 30)
      GenerateInsights.new.perform
      assert_equal(1, Insights::ProductsToImprove.count)
    end
  end
end
