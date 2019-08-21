require 'test_helper'

module Workarea
  module Storefront
    class GuestBrowsingIntegrationTest < Workarea::IntegrationTest
      include Storefront::IntegrationTest

      def test_checkout_with_guest_browsing
        admin_user = create_user(password: 'W3bl1nc!', super_admin: true)

        post storefront.login_path,
          params: { email: admin_user.email, password: 'W3bl1nc!' }

        post admin.guest_browsing_path

        complete_checkout
        order = Order.placed.first
        assert_nil(order.user_id)
        assert_equal('admin', order.source)
        assert_equal(order.checkout_by_id, admin_user.id.to_s)
      end
    end
  end
end
