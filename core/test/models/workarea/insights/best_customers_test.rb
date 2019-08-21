require 'test_helper'

module Workarea
  module Insights
    class BestCustomersTest < TestCase
      def test_results
        Metrics::User.save_order(email: 'bcrouse@workarea.com', revenue: 0.5.to_m, at: 120.days.ago)
        Metrics::User.save_order(email: 'bcrouse0@workarea.com', revenue: 1.to_m, at: 60.days.ago)
        Metrics::User.save_order(email: 'bcrouse1@workarea.com', revenue: 1.to_m, at: 1.day.ago)
        Metrics::User.save_order(email: 'bcrouse2@workarea.com', revenue: 10.to_m, at: 2.days.ago)
        Metrics::User.save_order(email: 'bcrouse2@workarea.com', revenue: 10.to_m, at: 3.days.ago)
        Metrics::User.save_order(email: 'bcrouse3@workarea.com', revenue: 20.to_m, at: 2.days.ago)
        Metrics::User.save_order(email: 'bcrouse3@workarea.com', revenue: 20.to_m, at: 3.days.ago)
        Metrics::User.save_order(email: 'bcrouse3@workarea.com', revenue: 20.to_m, at: 4.days.ago)
        Metrics::User.save_order(email: 'bcrouse4@workarea.com', revenue: 30.to_m, at: 1.days.ago)
        Metrics::User.save_order(email: 'bcrouse4@workarea.com', revenue: 30.to_m, at: 2.days.ago)
        5.times do |i|
          Metrics::User.save_order(email: "#{i + 5}@workarea.com", revenue: 10.to_m, at: 3.days.ago)
        end

        Metrics::UpdateUserAggregations.update!
        BestCustomers.generate_monthly!
        assert_equal(1, BestCustomers.count)

        best_customers = BestCustomers.first
        assert_equal(2, best_customers.results.length)
        assert_equal('bcrouse3@workarea.com', best_customers.results.first['_id'])
        assert_equal('bcrouse4@workarea.com', best_customers.results.second['_id'])
      end

      def test_falling_back_to_longer_timespans
        Metrics::User.save_order(email: 'bcrouse@workarea.com', revenue: 0.5.to_m, at: 600.days.ago)
        Metrics::User.save_order(email: 'bcrouse0@workarea.com', revenue: 1.to_m, at: 300.days.ago)
        Metrics::User.save_order(email: 'bcrouse1@workarea.com', revenue: 1.to_m, at: 31.day.ago)
        Metrics::User.save_order(email: 'bcrouse2@workarea.com', revenue: 10.to_m, at: 32.days.ago)
        Metrics::User.save_order(email: 'bcrouse2@workarea.com', revenue: 10.to_m, at: 33.days.ago)
        Metrics::User.save_order(email: 'bcrouse3@workarea.com', revenue: 20.to_m, at: 32.days.ago)
        Metrics::User.save_order(email: 'bcrouse3@workarea.com', revenue: 20.to_m, at: 33.days.ago)
        Metrics::User.save_order(email: 'bcrouse3@workarea.com', revenue: 20.to_m, at: 34.days.ago)
        Metrics::User.save_order(email: 'bcrouse4@workarea.com', revenue: 30.to_m, at: 31.days.ago)
        Metrics::User.save_order(email: 'bcrouse4@workarea.com', revenue: 30.to_m, at: 32.days.ago)

        Metrics::UpdateUserAggregations.update!
        BestCustomers.generate_monthly!
        assert_equal(1, BestCustomers.count)

        best_customers = BestCustomers.first
        assert_equal(2, best_customers.results.length)
        assert_equal('bcrouse3@workarea.com', best_customers.results.first['_id'])
        assert_equal('bcrouse4@workarea.com', best_customers.results.second['_id'])
      end
    end
  end
end
