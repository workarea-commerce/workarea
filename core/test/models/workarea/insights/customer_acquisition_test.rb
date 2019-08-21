require 'test_helper'

module Workarea
  module Insights
    class CustomerAcquisitionTest < TestCase
      def test_results
        Metrics::User.save_order(email: 'bcrouse0@workarea.com', revenue: 1.to_m, at: Time.zone.local(2018, 11, 1))
        Metrics::User.save_order(email: 'bcrouse1@workarea.com', revenue: 1.to_m, at: Time.zone.local(2018, 12, 1))
        Metrics::User.save_order(email: 'bcrouse2@workarea.com', revenue: 1.to_m, at: Time.zone.local(2018, 12, 2))
        Metrics::User.save_order(email: 'bcrouse2@workarea.com', revenue: 1.to_m, at: Time.zone.local(2018, 12, 4))
        Metrics::User.save_order(email: 'bcrouse3@workarea.com', revenue: 1.to_m, at: Time.zone.local(2018, 12, 5))
        Metrics::User.save_order(email: 'bcrouse3@workarea.com', revenue: 1.to_m, at: Time.zone.local(2018, 12, 14))
        Metrics::User.save_order(email: 'bcrouse3@workarea.com', revenue: 1.to_m, at: Time.zone.local(2018, 12, 15))
        Metrics::User.save_order(email: 'bcrouse4@workarea.com', revenue: 1.to_m, at: Time.zone.local(2018, 12, 24))
        Metrics::User.save_order(email: 'bcrouse4@workarea.com', revenue: 1.to_m, at: Time.zone.local(2018, 12, 25))
        travel_to Time.zone.local(2019, 1, 4)

        Metrics::UpdateUserAggregations.update!
        CustomerAcquisition.generate_monthly!
        assert_equal(1, CustomerAcquisition.count)

        customer_acquisition = CustomerAcquisition.first
        assert_equal(Time.zone.local(2018, 12, 1), customer_acquisition.results.first['date'])
        assert_equal(Time.zone.local(2018, 12, 2), customer_acquisition.results.second['date'])
        assert_equal(Time.zone.local(2018, 12, 31), customer_acquisition.results.last['date'])
        assert_equal(
          [1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
          customer_acquisition.results.map { |r| r['new_customers'] }
        )
      end

      def test_days_last_month
        travel_to Time.zone.local(2019, 1, 4)
        assert_equal(31, CustomerAcquisition.days_last_month)

        travel_to Time.zone.local(2018, 12, 1)
        assert_equal(30, CustomerAcquisition.days_last_month)

        travel_to Time.zone.local(2018, 3, 22)
        assert_equal(28, CustomerAcquisition.days_last_month)
      end
    end
  end
end
