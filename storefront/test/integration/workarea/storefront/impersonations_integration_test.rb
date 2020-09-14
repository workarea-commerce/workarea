require 'test_helper'

module Workarea
  module Storefront
    class ImpersonationsIntegrationTest < Workarea::IntegrationTest
      def test_ignores_ip_address_and_user_agent_validation_when_impersonating
        customer = create_user
        super_admin = create_user(password: 'W3bl1nc!', super_admin: true)
        post storefront.login_path,
          params: { email: super_admin.email, password: 'W3bl1nc!' }

        post admin.impersonations_path, params: { user_id: customer.id }
        customer.update_attributes!(ip_address: '173.252.132.26')

        get storefront.users_account_path
        refute(response.redirect?)
      end

      def test_stores_the_order_as_checked_out_by_the_admin
        super_admin = create_user(password: 'W3bl1nc!', super_admin: true)
        customer = create_user(email: 'bcrouse@workarea.com', password: 'W3bl1nc!')
        product = create_product
        create_shipping_service(
          name: 'Ground',
          tax_code: '001',
          rates: [{ price: 7.to_m }]
        )

        post storefront.login_path,
          params: { email: super_admin.email, password: 'W3bl1nc!' }

        post admin.impersonations_path,
          params: { user_id: customer.id }

        post storefront.cart_items_path,
          params: {
            product_id: product.id,
            sku: product.skus.first,
            quantity: 2
          }

        patch storefront.checkout_addresses_path,
          params: {
            billing_address: {
              first_name: 'Ben',
              last_name: 'Crouse',
              street: '12 N. 3rd St.',
              city: 'Philadelphia',
              region: 'PA',
              postal_code: '19106',
              country: 'US',
              phone_number: '2159251800'
            },
            shipping_address: {
              first_name: 'Ben',
              last_name: 'Crouse',
              street: '22 S. 3rd St.',
              city: 'Philadelphia',
              region: 'PA',
              postal_code: '19106',
              country: 'US',
              phone_number: '2159251800'
            }
          }

        patch storefront.checkout_place_order_path,
          params: {
            payment: 'new_card',
            credit_card: {
              number: '1',
              month: 1,
              year: next_year,
              cvv: '999'
            }
          }

        order = Order.first
        assert_equal(super_admin.id.to_s, order.checkout_by_id)
      end

      def test_dissociates_user_cart_after_impersonation_times_out
        super_admin = create_user(password: 'W3bl1nc!', super_admin: true)
        customer = create_user(email: 'bcrouse@workarea.com', password: 'W3bl1nc!')
        product = create_product
        create_shipping_service(
          name: 'Ground',
          tax_code: '001',
          rates: [{ price: 7.to_m }]
        )

        post storefront.login_path,
          params: { email: super_admin.email, password: 'W3bl1nc!' }

        post admin.impersonations_path, params: { user_id: customer.id }

        post storefront.cart_items_path,
          params: {
            product_id: product.id,
            sku: product.skus.first,
            quantity: 2
          }

        # simulate expiration of admin session.
        reset!

        # Cart should be empty now that admin is logged out
        get storefront.checkout_path
        assert_redirected_to(storefront.cart_path)
      end

      def test_allows_previewing_content_blocks_when_impersonating
        customer = create_user
        super_admin = create_user(password: 'W3bl1nc!', super_admin: true)
        post storefront.login_path,
          params: { email: super_admin.email, password: 'W3bl1nc!' }

        post admin.impersonations_path, params: { user_id: customer.id }

        get storefront.new_content_block_path(
          type_id: :html,
          content_id: create_content.id
        )

        assert(response.ok?)
      end

      def test_metrics_tracking
        super_admin = create_user(password: 'W3bl1nc!', super_admin: true)
        customer = create_user(email: 'bcrouse@workarea.com', password: 'W3bl1nc!')
        product = create_product
        create_shipping_service(
          name: 'Ground',
          tax_code: '001',
          rates: [{ price: 7.to_m }]
        )

        post storefront.login_path,
          params: { email: super_admin.email, password: 'W3bl1nc!' }

        admin_current_email_cookie = cookies[:email]

        post admin.impersonations_path,
          params: { user_id: customer.id }

        refute_equal(admin_current_email_cookie, cookies[:email])
        customer_current_email_cookie = cookies[:email]

        post storefront.cart_items_path,
          params: {
            product_id: product.id,
            sku: product.skus.first,
            quantity: 2
          }

        patch storefront.checkout_addresses_path,
          params: {
            billing_address: {
              first_name: 'Ben',
              last_name: 'Crouse',
              street: '12 N. 3rd St.',
              city: 'Philadelphia',
              region: 'PA',
              postal_code: '19106',
              country: 'US',
              phone_number: '2159251800'
            },
            shipping_address: {
              first_name: 'Ben',
              last_name: 'Crouse',
              street: '22 S. 3rd St.',
              city: 'Philadelphia',
              region: 'PA',
              postal_code: '19106',
              country: 'US',
              phone_number: '2159251800'
            }
          }

        assert_equal(customer_current_email_cookie, cookies[:email])

        patch storefront.checkout_place_order_path,
          params: {
            payment: 'new_card',
            credit_card: {
              number: '1',
              month: 1,
              year: next_year,
              cvv: '999'
            }
          }

        assert_equal(customer_current_email_cookie, cookies[:email])
        delete admin.impersonations_path
        assert_equal(admin_current_email_cookie, cookies[:email])

        super_admin_metrics = Metrics::User.find(super_admin.email)
        assert_equal(0, super_admin_metrics.orders)
        assert_equal(0, super_admin_metrics.revenue)

        customer_metrics = Metrics::User.find(customer.email)
        assert_equal(1, customer_metrics.orders)
        assert(customer_metrics.revenue.positive?)
      end
    end
  end
end
