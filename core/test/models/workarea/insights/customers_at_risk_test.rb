require 'test_helper'

module Workarea
  module Insights
    class CustomersAtRiskTest < TestCase
      def test_results
        Metrics::User.save_order(email: 'bcrouse0@workarea.com', revenue: 1.to_m, at: 60.days.ago)
        Metrics::User.save_order(email: 'bcrouse1@workarea.com', revenue: 1.to_m, at: 1.day.ago)
        Metrics::User.save_order(email: 'bcrouse2@workarea.com', revenue: 10.to_m, at: 2.days.ago)
        Metrics::User.save_order(email: 'bcrouse2@workarea.com', revenue: 10.to_m, at: 3.days.ago)
        Metrics::User.save_order(email: 'bcrouse3@workarea.com', revenue: 20.to_m, at: 2.days.ago)
        Metrics::User.save_order(email: 'bcrouse3@workarea.com', revenue: 20.to_m, at: 3.days.ago)
        Metrics::User.save_order(email: 'bcrouse3@workarea.com', revenue: 20.to_m, at: 4.days.ago)
        Metrics::User.save_order(email: 'bcrouse4@workarea.com', revenue: 30.to_m, at: 6.months.ago)
        Metrics::User.save_order(email: 'bcrouse4@workarea.com', revenue: 30.to_m, at: 6.months.ago)

        Metrics::UpdateUserAggregations.update!
        CustomersAtRisk.generate_monthly!
        assert_equal(1, CustomersAtRisk.count)
        at_risk = CustomersAtRisk.first
        assert_equal(1, at_risk.results.length)
        assert_equal('bcrouse4@workarea.com', at_risk.results.first['_id'])
      end
    end
  end
end
