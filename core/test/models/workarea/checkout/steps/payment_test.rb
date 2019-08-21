require 'test_helper'

module Workarea
  class Checkout
    module Steps
      class PaymentTest < TestCase
        setup :set_shipping_service, :set_product, :set_addresses

        def set_shipping_service
          create_shipping_service(
            name: 'Test',
            rates: [{ price: 5.to_m }],
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

        def payment
          @payment ||= checkout.payment
        end

        def step
          @step ||= Checkout::Steps::Payment.new(checkout)
        end

        def test_update
          assert(
            step.update(
              payment: 'new_card',
              credit_card: {
                number: '1',
                month: '1',
                year: Time.current.year + 1,
                cvv: '999'
              }
            )
          )

          assert(payment.credit_card.present?)
          assert(payment.credit_card.amount)

          step.update
          assert(payment.credit_card.nil?)

          payment.address = nil
          refute(step.update)
        end

        def test_complete?
          step.update(
            payment: 'new_card',
            credit_card: {
              number: '1',
              month: '1',
              year: Time.current.year + 1,
              cvv: '999'
            }
          )

          assert(step.complete?)

          payment.credit_card.amount = 0
          refute(step.complete?)

          payment.credit_card.amount = order.total_price
          order.email = nil
          refute(step.complete?)

          order.email = 'test@workarea.com'
          order.items = []
          refute(step.complete?)
        end
      end
    end
  end
end
