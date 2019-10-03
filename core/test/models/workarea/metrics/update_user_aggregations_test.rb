require 'test_helper'

module Workarea
  module Metrics
    class UpdateUserAggregationsTest < TestCase
      def test_update_calculated_fields!
        freeze_time
        Metrics::User.create!(id: 'bcrouse0@workarea.com')
        User.save_order(email: 'bcrouse1@workarea.com', revenue: 1.to_m, at: 1.day.ago)
        User.save_order(email: 'bcrouse2@workarea.com', revenue: 10.to_m, at: 2.days.ago)
        User.save_order(email: 'bcrouse2@workarea.com', revenue: 20.to_m, at: 3.days.ago)
        UpdateUserAggregations.update_calculated_fields!

        one = User.find('bcrouse1@workarea.com')
        assert_equal(1, one.average_order_value)
        assert_in_delta(1.46e-08, one.frequency)

        two = User.find('bcrouse2@workarea.com')
        assert_equal(15, two.average_order_value)
        assert_in_delta(1.29e-08, two.frequency)
      end

      def test_update_percentiles!
        Metrics::User.create!(id: 'bcrouse0@workarea.com')
        User.save_order(email: 'bcrouse1@workarea.com', revenue: 100.to_m, at: 30.days.ago)
        User.save_order(email: 'bcrouse2@workarea.com', revenue: 1.to_m, at: 2.days.ago)
        User.save_order(email: 'bcrouse2@workarea.com', revenue: 2.to_m, at: 3.days.ago)
        UpdateUserAggregations.update_calculated_fields!
        UpdateUserAggregations.update_percentiles!

        one = User.find('bcrouse1@workarea.com')
        assert_equal(50, one.orders_percentile)
        assert_equal(50, one.frequency_percentile)
        assert_equal(100, one.revenue_percentile)
        assert_equal(100, one.average_order_value_percentile)

        two = User.find('bcrouse2@workarea.com')
        assert_equal(100, two.orders_percentile)
        assert_equal(100, two.frequency_percentile)
        assert_equal(50, two.revenue_percentile)
        assert_equal(50, two.average_order_value_percentile)
      end

      def test_zero_orders
        metrics = Metrics::User.create!(id: 'test@workarea.com')

        assert_nothing_raised do
          UpdateUserAggregations.update_calculated_fields!
          UpdateUserAggregations.update_percentiles!
        end

        metrics.reload
        assert_nil(metrics.average_order_value)
        assert_nil(metrics.frequency)
        assert_nil(metrics.orders_percentile)
        assert_nil(metrics.frequency_percentile)
        assert_nil(metrics.revenue_percentile)
        assert_nil(metrics.average_order_value_percentile)
      end
    end
  end
end
