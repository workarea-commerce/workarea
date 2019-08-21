require 'test_helper'

module Workarea
  module Navigation
    class SortNavigationMenusByOrdersTest < TestCase
      def test_sorting_by_sales
        menu_one = create_menu(position: 1)
        menu_two = create_menu(position: 2)
        menu_three = create_menu(position: 3)
        menu_four = create_menu(position: 4)

        Metrics::MenuByDay.inc(key: { menu_id: menu_one.id }, orders: 1)
        Metrics::MenuByDay.inc(key: { menu_id: menu_two.id }, orders: 2)
        Metrics::MenuByDay.inc(key: { menu_id: menu_three.id }, orders: 3)

        SortNavigationMenusByOrders.perform

        assert_equal(0, menu_three.reload.position)
        assert_equal(1, menu_two.reload.position)
        assert_equal(2, menu_one.reload.position)
        assert(menu_four.reload.position.present?)
      end
    end
  end
end
