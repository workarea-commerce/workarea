require 'test_helper'

module Workarea
  module Metrics
    class UserTest < TestCase
      def test_save_order
        first = Time.zone.local(2018, 11, 14)
        User.save_order(
          email: 'bcrouse@workarea.com',
          revenue: 5.to_m,
          discounts: -1.to_m,
          at: first
        )

        assert_equal(1, User.count)

        user = User.first
        assert_equal(first.to_i, user.first_order_at.to_i)
        assert_equal(first.to_i, user.last_order_at.to_i)
        assert_equal(1, user.orders)
        assert_equal(5, user.revenue)
        assert_equal(-1, user.discounts)

        last = Time.zone.local(2018, 11, 15)
        User.save_order(
          email: 'bcrouse@workarea.com',
          revenue: 3.to_m,
          discounts: -1.to_m,
          at: last
        )

        assert_equal(1, User.count)

        user.reload
        assert_equal(first.to_i, user.first_order_at.to_i)
        assert_equal(last.to_i, user.last_order_at.to_i)
        assert_equal(2, user.orders)
        assert_equal(8, user.revenue)
        assert_equal(-2, user.discounts)
      end

      def test_update_calculated_fields!
        freeze_time
        User.save_order(email: 'bcrouse1@workarea.com', revenue: 1.to_m, at: 1.day.ago)
        User.save_order(email: 'bcrouse2@workarea.com', revenue: 10.to_m, at: 2.days.ago)
        User.save_order(email: 'bcrouse2@workarea.com', revenue: 20.to_m, at: 3.days.ago)
        User.update_calculated_fields!

        one = User.find('bcrouse1@workarea.com')
        assert_equal(1, one.average_order_value)
        assert_in_delta(1.46e-08, one.frequency)

        two = User.find('bcrouse2@workarea.com')
        assert_equal(15, two.average_order_value)
        assert_in_delta(1.29e-08, two.frequency)
      end

      def test_update_percentiles!
        User.save_order(email: 'bcrouse1@workarea.com', revenue: 100.to_m, at: 30.days.ago)
        User.save_order(email: 'bcrouse2@workarea.com', revenue: 1.to_m, at: 2.days.ago)
        User.save_order(email: 'bcrouse2@workarea.com', revenue: 2.to_m, at: 3.days.ago)
        User.update_calculated_fields!
        User.update_percentiles!

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

      def test_merging_metrics
        freeze_time

        first = User.create!(
          first_order_at: 2.weeks.ago,
          last_order_at: 1.day.ago,
          orders: 2,
          revenue: 100,
          discounts: -10,
          average_order_value: 50,
        )

        first.merge!(User.new)
        first.reload
        assert_equal(1, Metrics::User.count)
        assert_equal(2.weeks.ago, first.first_order_at)
        assert_equal(1.day.ago, first.last_order_at)
        assert_equal(2, first.orders)
        assert_equal(100, first.revenue)
        assert_equal(-10, first.discounts)
        assert_equal(50, first.average_order_value)

        second = User.create!(id: 'foo').tap { |u| u.merge!(first) }
        second.reload
        assert_equal(1, Metrics::User.count)
        assert_equal(2.weeks.ago, second.first_order_at)
        assert_equal(1.day.ago, second.last_order_at)
        assert_equal(2, second.orders)
        assert_equal(100, second.revenue)
        assert_equal(-10, second.discounts)
        assert_equal(50, second.average_order_value)

        third = User.create!(
          first_order_at: 3.weeks.ago,
          last_order_at: 3.weeks.ago,
          orders: 2,
          revenue: 120,
          average_order_value: 60,
        )

        third.merge!(second)
        third.reload
        assert_equal(1, Metrics::User.count)
        assert_equal(3.weeks.ago, third.first_order_at)
        assert_equal(1.day.ago, third.last_order_at)
        assert_equal(4, third.orders)
        assert_equal(220, third.revenue)
        assert_equal(-10, third.discounts)
        assert_equal(55, third.average_order_value)
      end
    end
  end
end
