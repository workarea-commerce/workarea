require 'test_helper'

module Workarea
  module Storefront
    module Users
      class OrdersIntegrationTest < Workarea::IntegrationTest
        def test_is_forbidden_if_the_user_does_not_own_the_order
          set_current_user(create_user)
          get storefront.users_order_path(create_placed_order)
          assert_equal(403, response.status)
        end
      end
    end
  end
end
