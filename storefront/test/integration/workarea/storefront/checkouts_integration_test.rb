require 'test_helper'

module Workarea
  module Storefront
    class CheckoutsIntegrationTest < Workarea::IntegrationTest
      include Storefront::IntegrationTest

      def test_failed_response_from_xhr_request_for_expired_checkout
        product = create_product
        shipping_service = create_shipping_service

        post storefront.cart_items_path,
          params: {
            product_id: product.id,
            sku: product.skus.first,
            quantity: 2
          }

        patch storefront.checkout_shipping_path,
          params: { shipping_service: shipping_service.name },
          xhr: true

        assert_equal(200, response.status)

        travel_to((Workarea.config.checkout_expiration + 1.hour).from_now) do
          patch storefront.checkout_shipping_path,
            params: { shipping_service: shipping_service.name },
            xhr: true

          assert_equal(422, response.status)
          assert_match('text/javascript', response['Content-Type'])
        end
      end

      def test_admin_redirecting_after_placing_order
        set_current_user(create_user(admin: true, orders_access: false))
        complete_checkout
        assert_redirected_to(storefront.checkout_confirmation_path)

        set_current_user(create_user(admin: true, orders_access: true))
        complete_checkout
        assert_redirected_to(admin.order_path(Order.desc(:created_at).first))
      end

      def test_setting_order_source
        product = create_product

        post storefront.cart_items_path,
          params: {
            product_id: product.id,
            sku: product.skus.first,
            quantity: 2
          }

        get storefront.checkout_addresses_path

        order = Order.last
        assert_equal('storefront', order.source)

        admin = create_user(admin: true, orders_access: true)
        set_current_admin(admin)

        get storefront.checkout_addresses_path

        order.reload
        assert_equal('admin', order.source)
      end

      def test_updating_checkout_with_order_locked
        product = create_product
        shipping_service = create_shipping_service

        post storefront.cart_items_path,
          params: {
            product_id: product.id,
            sku: product.skus.first,
            quantity: 2
          }

        order = Order.last
        order.lock!

        get storefront.checkout_shipping_path
        assert(response.ok?)

        patch storefront.checkout_shipping_path,
          params: { shipping_service: shipping_service.name }

        assert_redirected_to(storefront.cart_path)
        assert(flash[:error].present?)

        patch storefront.checkout_shipping_path,
          params: { shipping_service: shipping_service.name },
          xhr: true

        assert_response(:conflict)
        assert(flash[:error].present?)

        order.unlock!
      end

      def test_changing_email_address_in_guest_checkout
        product = create_product
        shipping_service = create_shipping_service

        post storefront.cart_items_path,
          params: {
            product_id: product.id,
            sku: product.skus.first,
            quantity: 1
          }

        get storefront.checkout_addresses_path
        patch storefront.checkout_addresses_path,
          params: {
            email: 'bcrouse@workarea.com',
            billing_address: {
              first_name:   'Ben',
              last_name:    'Crouse',
              street:       '12 N. 3rd St.',
              city:         'Philadelphia',
              region:       'PA',
              postal_code:  '19106',
              country:      'US',
              phone_number: '2159251800'
            },
            shipping_address: {
              first_name:   'Ben',
              last_name:    'Crouse',
              street:       '22 S. 3rd St.',
              city:         'Philadelphia',
              region:       'PA',
              postal_code:  '19106',
              country:      'US',
              phone_number: '2159251800'
            }
          }
        get storefront.checkout_shipping_path
        patch storefront.checkout_shipping_path

        get storefront.checkout_payment_path

        assert_equal(1, Order.count)
        assert_equal('bcrouse@workarea.com', Order.first.email)
        assert_equal(0, Payment::Profile.count)
        assert(cookies[:email].present?)
        original_email_cookie = cookies[:email]

        get storefront.checkout_addresses_path
        patch storefront.checkout_addresses_path,
          params: {
            email: 'bcrouse@weblinc.com',
            billing_address: {
              first_name:   'Ben',
              last_name:    'Crouse',
              street:       '12 N. 3rd St.',
              city:         'Philadelphia',
              region:       'PA',
              postal_code:  '19106',
              country:      'US',
              phone_number: '2159251800'
            },
            shipping_address: {
              first_name:   'Ben',
              last_name:    'Crouse',
              street:       '22 S. 3rd St.',
              city:         'Philadelphia',
              region:       'PA',
              postal_code:  '19106',
              country:      'US',
              phone_number: '2159251800'
            }
          }

        get storefront.checkout_shipping_path
        patch storefront.checkout_shipping_path

        get storefront.checkout_payment_path
        patch storefront.checkout_place_order_path,
          params: {
            payment: 'new_card',
            credit_card: {
              number: '2',
              month:  1,
              year:   next_year,
              cvv:    '999'
            }
          }

        order = Order.first
        payment_profile = Payment::Profile.first
        assert_equal(1, Order.count)
        assert_equal('bcrouse@weblinc.com', order.email)
        assert_equal(1, Payment::Profile.count)
        assert_equal('bcrouse@weblinc.com', payment_profile.email)
        assert_includes(payment_profile.reference, order.id)
        assert(cookies[:email].present?)
        refute_equal(original_email_cookie, cookies[:email])
      end

      def test_setting_traffic_referrer
        cookies['workarea_referrer'] = 'https://www.google.com/'
        product = create_product

        post storefront.cart_items_path,
          params: {
            product_id: product.id,
            sku: product.skus.first,
            quantity: 2
          }

        get storefront.checkout_addresses_path

        order = Order.last
        assert_equal('Google', order.traffic_referrer.source)
        assert_equal('search', order.traffic_referrer.medium)
        assert_equal('https://www.google.com/', order.traffic_referrer.uri)

        cookies['workarea_referrer'] = 'https://www.workarea.com/'

        get storefront.checkout_addresses_path

        order = Order.last
        assert_nil(order.traffic_referrer.source)
        assert_nil(order.traffic_referrer.medium)
        assert_equal('https://www.workarea.com/', order.traffic_referrer.uri)
      end

      def test_saving_segment_ids
        create_life_cycle_segments
        product = create_product

        post storefront.cart_items_path,
          params: { product_id: product.id, sku: product.skus.first }

        get storefront.checkout_addresses_path
        assert_equal(
          [Segment::FirstTimeVisitor.instance.id],
          Order.desc(:updated_at).first.segment_ids
        )
      end

      def test_saving_fraud_decision
        complete_checkout
        order = Order.desc(:created_at).first

        assert(order.fraud_decision.present?)
        assert(order.placed?)
        refute(order.fraud_suspected_at.present?)
        assert(order.fraud_decided_at.present?)
        assert_equal(:no_decision, order.fraud_decision.decision)

        post storefront.cart_items_path,
          params: {
            product_id: product.id,
            sku: product.skus.first,
            quantity: 1
          }

        get storefront.checkout_addresses_path
        patch storefront.checkout_addresses_path,
          params: {
            email: 'decline@workarea.com',
            billing_address: {
              first_name:   'Ben',
              last_name:    'Crouse',
              street:       '12 N. 3rd St.',
              city:         'Philadelphia',
              region:       'PA',
              postal_code:  '19106',
              country:      'US',
              phone_number: '2159251800'
            },
            shipping_address: {
              first_name:   'Ben',
              last_name:    'Crouse',
              street:       '22 S. 3rd St.',
              city:         'Philadelphia',
              region:       'PA',
              postal_code:  '19106',
              country:      'US',
              phone_number: '2159251800'
            }
          }
        get storefront.checkout_shipping_path
        patch storefront.checkout_shipping_path

        get storefront.checkout_payment_path

        patch storefront.checkout_place_order_path,
          params: {
            payment: 'new_card',
            credit_card: {
              number: '2',
              month:  1,
              year:   next_year,
              cvv:    '999'
            }
          }

        order = Order.desc(:created_at).first

        assert_equal(:declined, order.fraud_decision.decision)
        assert(order.fraud_suspected_at.present?)
        assert(order.fraud_decided_at.present?)
        refute(order.placed?)
      end

      def test_no_valid_shipping_options
        product = create_product

        post storefront.cart_items_path,
          params: {
            product_id: product.id,
            sku: product.skus.first,
            quantity: 2
          }

        get storefront.checkout_addresses_path

        patch storefront.checkout_addresses_path,
          params: {
            email: 'bcrouse@weblinc.com',
            billing_address: {
              first_name:   'Ben',
              last_name:    'Crouse',
              street:       '12 N. 3rd St.',
              city:         'Philadelphia',
              region:       'PA',
              postal_code:  '19106',
              country:      'US',
              phone_number: '2159251800'
            },
            shipping_address: {
              first_name:   'Ben',
              last_name:    'Crouse',
              street:       '22 S. 3rd St.',
              city:         'Philadelphia',
              region:       'PA',
              postal_code:  '19106',
              country:      'US',
              phone_number: '2159251800'
            }
          }

        assert(flash[:error].present?)
      end

      def test_not_setting_a_blank_tracking_email
        cookies[:email] = 'foo@bar.com'
        get storefront.checkout_shipping_path
        assert_equal('foo@bar.com', cookies[:email])
      end

      def test_no_required_shipping_address_options_flash_message
        product = create_product(name: 'Digital Product', variants: [{ sku: 'SKU' }])
        create_fulfillment_sku(id: 'SKU', policy: :download, file: product_image_file_path)

        post storefront.cart_items_path,
          params: { product_id: product.id, sku: product.skus.first, quantity: 1 }

        get storefront.checkout_addresses_path

        patch storefront.checkout_addresses_path,
          params: {
            email: 'bcrouse@weblinc.com',
            billing_address: {
              first_name:   'Ben',
              last_name:    'Crouse',
              street:       '12 N. 3rd St.',
              city:         'Philadelphia',
              region:       'PA',
              postal_code:  '19106',
              country:      'US',
              phone_number: '2159251800'
            }
          }

        refute(flash[:error].present?)
      end
    end
  end
end
