require 'test_helper'

module Workarea
  module Admin
    class UserViewModelTest < TestCase
      def test_orders
        email = 'test@example.com'
        guest_order = OrderViewModel.wrap(create_placed_order(email: email))
        user = UserViewModel.wrap(create_user(email: email))
        logged_in_order = OrderViewModel.wrap(
          create_placed_order(
            id: '5678',
            email: 'test@example.com',
            user_id: user.id
          )
        )
        unplaced_order = OrderViewModel.wrap(create_order(email: email))

        assert_includes(user.orders, logged_in_order)
        assert_includes(user.orders, guest_order)
        refute_includes(user.orders, unplaced_order)
        assert_equal([logged_in_order, guest_order], user.orders)
      end
    end
  end
end
