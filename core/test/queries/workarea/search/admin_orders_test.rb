require 'test_helper'

module Workarea
  module Search
    class AdminOrdersTest < IntegrationTest
      setup :create_orders

      def create_orders
        @one = create_placed_order(id: '1', total_price: 1.to_m, placed_at: Time.zone.local(2016, 8, 24))
        @two = create_placed_order(id: '2', total_price: 2.to_m, placed_at: Time.zone.local(2016, 8, 25, 10))
        @three = create_placed_order(id: '3', total_price: 3.to_m, placed_at: Time.zone.local(2016, 8, 26))
        @four = create_placed_order(id: '4', total_price: 4.to_m, placed_at: Time.zone.local(2016, 8, 27))
      end

      def test_tracking_number
        fulfillment = Fulfillment.find(@one.id)
        fulfillment.ship_items('f0085', [{ id: @one.items.first.id, quantity: 1 }])

        search = AdminOrders.new(q: 'f0085')
        assert_equal(1, search.total)
        assert_includes(search.results, @one)
      end

      def test_filter
        search = AdminOrders.new(total_price_greater_than: 2)
        assert_equal(3, search.total)
        assert_includes(search.results, @two)
        assert_includes(search.results, @three)

        search = AdminOrders.new(total_price_less_than: 2)
        assert_equal(1, search.total)
        assert_includes(search.results, @one)
      end

      def test_sort
        search = AdminOrders.new(sort: 'total')
        assert_equal([@four, @three, @two, @one], search.results)

        search = AdminOrders.new(sort: 'oldest_placed')
        assert_equal([@one, @two, @three, @four], search.results)
        assert_equal(Sort.oldest_placed, search.current_sort)

        search = AdminOrders.new(sort: 'newest_placed')
        assert_equal([@four, @three, @two, @one], search.results)
        assert_equal(Sort.newest_placed, search.current_sort)
      end

      def test_filter_by_date
        search = AdminOrders.new(placed_at_greater_than: '2016-08-26')
        assert_equal(2, search.total)

        search = AdminOrders.new(placed_at_greater_than: '2016-08-25')
        assert_equal(3, search.total)

        search = AdminOrders.new(
          placed_at_greater_than: '2016-08-26',
          placed_at_less_than: '2016-08-26'
        )
        assert_equal(1, search.total)
      end
    end
  end
end
