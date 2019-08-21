require 'test_helper'

module Workarea
  class Checkout
    module Steps
      class ShippingTest < TestCase
        setup :set_shipping_service, :set_product, :set_addresses

        def set_shipping_service
          create_shipping_service(
            name: 'Ground',
            rates: [{ price: 5.to_m }],
            tax_code: '001'
          )

          create_shipping_service(
            name: 'Expedited',
            rates: [{ price: 15.to_m }],
            tax_code: '001'
          )
        end

        def set_product
          create_product(id: 'PROD')
        end

        def set_addresses
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

          Addresses.new(checkout).update(
            shipping_address: address_params,
            billing_address: address_params
          )
        end

        def order
          @order ||= create_order(
            email: 'test@workarea.com',
            items: [{ product_id: 'PROD', sku: 'SKU' }]
          )
        end

        def checkout
          @checkout ||= Checkout.new(order)
        end

        def shipping
          @payment ||= checkout.shipping
        end

        def step
          @step ||= Checkout::Steps::Shipping.new(checkout)
        end

        def test_update
          assert(step.update)
          assert_equal('Ground', shipping.shipping_service.name)

          assert(step.update(shipping_service: 'Expedited'))
          assert_equal('Expedited', shipping.shipping_service.name)

          assert(step.update(shipping_instructions: 'Please do not knock'))
          assert_equal('Please do not knock', shipping.instructions)

          assert(step.update(shipping_instructions: ''))
          assert_equal('', shipping.instructions)

          shipping.address.street = nil
          shipping.shipping_service = nil
          step.update(shipping_service: 'Ground')

          assert_nil(shipping.shipping_service)

          order.items = []
          assert(step.update)

          assert_raises(Mongoid::Errors::DocumentNotFound) do
            shipping.reload
          end
        end

        def test_complete?
          assert(step.complete?)

          step.update(shipping_service: 'Expedited')
          assert(step.complete?)

          shipping.address.street = nil
          refute(step.complete?)

          order.items = []
          assert(step.complete?)
        end
      end
    end
  end
end
