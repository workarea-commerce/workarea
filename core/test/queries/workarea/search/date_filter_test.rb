require 'test_helper'

module Workarea
  module Search
    class DateFilterTest < TestCase
      def test_query_value
        search = AdminOrders.new(placed_at_greater_than: '2016-08-26')
        filter = DateFilter.new(search, 'placed_at', :gte)
        assert_equal(Time.zone.local(2016, 8, 26), filter.query_value)

        search = AdminOrders.new(
          placed_at_greater_than: '2016-08-26',
          placed_at_less_than: '2016-08-30'
        )
        filter = DateFilter.new(search, 'placed_at', :gte)
        assert_equal(Time.zone.local(2016, 8, 26), filter.query_value)
        filter = DateFilter.new(search, 'placed_at', :lt)
        assert_equal(Time.zone.local(2016, 8, 30).end_of_day, filter.query_value)

        search = AdminOrders.new(
          placed_at_greater_than: '2016-08-26',
          placed_at_less_than: '2016-08-26'
        )
        filter = DateFilter.new(search, 'placed_at', :gte)
        assert_equal(Time.zone.local(2016, 8, 26), filter.query_value)
        filter = DateFilter.new(search, 'placed_at', :lt)
        assert_equal(Time.zone.local(2016, 8, 26).end_of_day, filter.query_value)
      end

      def test_time_specified?
        search = AdminOrders.new(placed_at_greater_than: '2016-08-26')
        refute(DateFilter.new(search, 'placed_at', :gte).time_specified?)

        search = AdminOrders.new(placed_at_greater_than: '2019-03-06T14:00:00-05:00')
        assert(DateFilter.new(search, 'placed_at', :gte).time_specified?)
      end
    end
  end
end
