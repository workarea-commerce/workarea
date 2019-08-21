require 'test_helper'

module Workarea
  module Storefront
    class OrderLookupIntegrationTest < Workarea::IntegrationTest
      def test_redirects_to_the_order_on_match
        order = create_placed_order
        payment = Payment.find(order.id)

        post storefront.lookup_orders_path,
          params: {
            order_id: order.id,
            postal_code: payment.address.postal_code
          }

        assert(session[:lookup_order_id].present?)
        assert_redirected_to storefront.order_path(order)
      end

      def test_redirects_back_on_no_match
        order = create_placed_order
        payment = Payment.find(order.id)

        post storefront.lookup_orders_path,
          params: {
            order_id: "#{order.id}FOO",
            postal_code: payment.address.postal_code
          }

        assert_redirected_to(storefront.check_orders_path)
        assert(session[:lookup_order_id].blank?)
        assert(flash[:error].present?)

        post storefront.lookup_orders_path,
          params: {
            order_id: order.id,
            postal_code: 'foobar'
          }

        assert_redirected_to(storefront.check_orders_path)
        assert(session[:lookup_order_id].blank?)
        assert(flash[:error].present?)
      end

      def test_clearing_lookup_order_without_match
        order = create_placed_order
        payment = Payment.find(order.id)

        post storefront.lookup_orders_path,
          params: {
            order_id: order.id,
            postal_code: payment.address.postal_code
          }

        assert(session[:lookup_order_id].present?)
        assert_redirected_to storefront.order_path(order)

        post storefront.lookup_orders_path,
          params: {
            order_id: order.id,
            postal_code: 'foobar'
          }

        assert_redirected_to(storefront.check_orders_path)
        assert(session[:lookup_order_id].blank?)
        assert(flash[:error].present?)
      end

      def test_showing_order_without_lookup
        order = create_placed_order(user_id: create_user.id)
        get storefront.order_path(order)

        refute(response.ok?)
        assert_redirected_to(storefront.check_orders_path)
        assert(flash[:error].present?)
      end

      def test_checking_different_lookup_order
        order = create_placed_order(id: '1')
        payment = Payment.find(order.id)

        other_order = create_placed_order(id: '2')

        post storefront.lookup_orders_path,
          params: {
            order_id: order.id,
            postal_code: payment.address.postal_code
          }

        get storefront.order_path(order)
        assert(response.ok?)

        get storefront.order_path(other_order)
        refute(response.ok?)
        assert_redirected_to(storefront.check_orders_path)
        assert(flash[:error].present?)
      end

      def test_lookup_order_status_from_url
        order = create_placed_order
        payment = Payment.find(order.id)

        get storefront.orders_path(
          order_id: order.id,
          postal_code: payment.address.postal_code
        )

        assert_redirected_to(storefront.order_path(order))

        follow_redirect!

        assert_nil(flash[:error])
        assert_response(:success)
      end
    end
  end
end
