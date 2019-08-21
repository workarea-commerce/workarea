require 'test_helper'

module Workarea
  module Insights
    class LowAovCustomersTest < TestCase
      def test_results
        Metrics::User.save_order(email: 'bcrouse1@workarea.com', revenue: 10.to_m)
        Metrics::User.save_order(email: 'bcrouse1@workarea.com', revenue: 10.to_m)
        Metrics::User.save_order(email: 'bcrouse2@workarea.com', revenue: 20.to_m)
        Metrics::User.save_order(email: 'bcrouse2@workarea.com', revenue: 20.to_m)
        Metrics::User.save_order(email: 'bcrouse3@workarea.com', revenue: 3.to_m)
        Metrics::User.save_order(email: 'bcrouse3@workarea.com', revenue: 3.to_m)
        Metrics::User.save_order(email: 'bcrouse3@workarea.com', revenue: 3.to_m)
        Metrics::User.save_order(email: 'bcrouse4@workarea.com', revenue: 40.to_m)
        Metrics::User.save_order(email: 'bcrouse5@workarea.com', revenue: 5.to_m, at: 60.days.ago)
        Metrics::User.save_order(email: 'bcrouse5@workarea.com', revenue: 5.to_m, at: 60.days.ago)
        Metrics::User.save_order(email: 'bcrouse5@workarea.com', revenue: 5.to_m, at: 60.days.ago)

        Metrics::UpdateUserAggregations.update!

        LowAovCustomers.generate_monthly!
        assert_equal(1, LowAovCustomers.count)
        low_aov = LowAovCustomers.first
        assert_equal(1, low_aov.results.length)
        assert_equal('bcrouse3@workarea.com', low_aov.results.first['_id'])
        assert_equal(3, low_aov.results.first['average_order_value'])
      end
    end
  end
end
