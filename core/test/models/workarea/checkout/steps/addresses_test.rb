require 'test_helper'

module Workarea
  class Checkout
    module Steps
      class AddressesTest < TestCase
        setup :set_shipping_service

        def order
          @order ||= create_order(
            email: 'test@workarea.com',
            items: [{ product_id: 'PROD', sku: 'SKU' }]
          )
        end

        def set_shipping_service
          create_shipping_service(
            name: 'Test',
            rates: [{ price: 5.to_m }],
            tax_code: '001'
          )
        end

        def test_update
          checkout = Checkout.new(order)
          step = Addresses.new(checkout)

          step.update(email: 'new_test@workarea.com')
          assert_equal('new_test@workarea.com', order.email)

          user = User.new(email: 'user_test@workarea.com')
          checkout = Checkout.new(order, user)
          step = Addresses.new(checkout)
          step.update

          assert_equal('user_test@workarea.com', order.email)
          assert(checkout.shipping.reload.shipping_service.blank?)

          checkout = Checkout.new(order)
          step = Addresses.new(checkout)

          step.update(
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
          )

          shipping = checkout.shipping
          shipping.reload

          assert_equal('Ben', shipping.address.first_name)
          assert_equal('Crouse', shipping.address.last_name)
          assert_equal('22 S. 3rd St.', shipping.address.street)
          assert_equal('Philadelphia', shipping.address.city)
          assert_equal('PA', shipping.address.region)
          assert_equal('19106', shipping.address.postal_code)
          assert_equal(Country['US'], shipping.address.country)
          assert_equal('2159251800', shipping.address.phone_number)

          assert_equal('Test', shipping.shipping_service.name)
          assert_equal('001', shipping.shipping_service.tax_code)

          checkout = Checkout.new(order)
          step = Addresses.new(checkout)

          step.update(
            billing_address: {
              first_name:   'Ben',
              last_name:    'Crouse',
              street:       '22 S. 3rd St.',
              city:         'Philadelphia',
              region:       'PA',
              postal_code:  '19106',
              country:      'US',
              phone_number: '2159251800'
            }
          )

          assert_equal('Ben', checkout.payment.address.first_name)
          assert_equal('Crouse', checkout.payment.address.last_name)
          assert_equal('22 S. 3rd St.', checkout.payment.address.street)
          assert_equal('Philadelphia', checkout.payment.address.city)
          assert_equal('PA', checkout.payment.address.region)
          assert_equal('19106', checkout.payment.address.postal_code)
          assert_equal(Country['US'], checkout.payment.address.country)
          assert_equal('2159251800', checkout.payment.address.phone_number)
        end

        def test_complete?
          checkout = Checkout.new(order)
          step = Addresses.new(checkout)

          address_params = {
            first_name:   'Ben',
            last_name:    'Crouse',
            street:       '22 S. 3rd St.',
            city:         'Philadelphia',
            region:       'PA',
            postal_code:  '19106',
            country:      'US',
            phone_number: '2159251800'
          }

          step.update(
            shipping_address: address_params,
            billing_address: address_params
          )
          assert(step.complete?)

          checkout.payment.address = nil
          refute(step.complete?)

          checkout.payment.set_address(address_params)
          checkout.shipping.address = nil
          refute(step.complete?)
        end
      end
    end
  end
end
