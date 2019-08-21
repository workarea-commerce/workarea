require 'test_helper'

module Workarea
  module Insights
    class RepeatPurchaseRateTest < TestCase
      def test_results
        Metrics::User.save_order(email: 'bcrouse0@workarea.com', revenue: 1.to_m, at: 80.days.ago)
        Metrics::User.save_order(email: 'bcrouse0@workarea.com', revenue: 1.to_m, at: 40.days.ago)
        Metrics::User.save_order(email: 'bcrouse0@workarea.com', revenue: 1.to_m, at: 20.days.ago)
        Metrics::User.save_order(email: 'bcrouse0@workarea.com', revenue: 1.to_m, at: 10.days.ago)
        Metrics::User.save_order(email: 'bcrouse1@workarea.com', revenue: 1.to_m, at: 40.days.ago)
        Metrics::User.save_order(email: 'bcrouse1@workarea.com', revenue: 1.to_m, at: 20.days.ago)
        Metrics::User.save_order(email: 'bcrouse2@workarea.com', revenue: 1.to_m, at: 10.days.ago)

        RepeatPurchaseRate.generate_monthly!
        assert_equal(1, RepeatPurchaseRate.count)

        repeat_purchase_rate = RepeatPurchaseRate.first
        assert_equal(3, repeat_purchase_rate.results.length)

        assert_equal(30, repeat_purchase_rate.results.first['days_ago'])
        assert_equal(1, repeat_purchase_rate.results.first['purchased'])
        assert_equal(0, repeat_purchase_rate.results.first['purchased_again'])
        assert_in_delta(0, repeat_purchase_rate.results.first['percent_purchased_again'])

        assert_equal(60, repeat_purchase_rate.results.second['days_ago'])
        assert_equal(2, repeat_purchase_rate.results.second['purchased'])
        assert_equal(1, repeat_purchase_rate.results.second['purchased_again'])
        assert_in_delta(50, repeat_purchase_rate.results.second['percent_purchased_again'])

        assert_equal(90, repeat_purchase_rate.results.third['days_ago'])
        assert_equal(3, repeat_purchase_rate.results.third['purchased'])
        assert_equal(2, repeat_purchase_rate.results.third['purchased_again'])
        assert_in_delta(66.667, repeat_purchase_rate.results.third['percent_purchased_again'])
      end
    end
  end
end
