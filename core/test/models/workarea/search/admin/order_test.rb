require 'test_helper'

module Workarea
  module Search
    class Admin
      class OrderTest < Workarea::TestCase
        def test_search_text_includes_discount_ids
          order = Workarea::Order.new(created_at: Time.current)

          order.items.build
          order.items.first.adjust_pricing(data: { 'discount_id' => '1' })
          order.items.first.adjust_pricing(data: { 'discount_id' => '2' })

          assert_includes(Order.new(order).search_text, '1')
          assert_includes(Order.new(order).search_text, '2')
        end

        def test_search_test_includes_shipping_address_info
          order = Workarea::Order.new(created_at: Time.current)

          Shipping.create!(
            order_id: order.id,
            address: {
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

          result = Order.new(order).search_text
          assert_includes(result, 'Ben')
          assert_includes(result, 'Crouse')
          assert_includes(result, '22 S. 3rd St.')
          assert_includes(result, 'Philadelphia')
          assert_includes(result, 'PA')
          assert_includes(result, '19106')
          assert_includes(result, 'US')
          assert_includes(result, '2159251800')
        end

        def test_includes_payment_address_info
          order = Workarea::Order.new(created_at: Time.current)

          Payment.create!(
            id: order.id,
            address: {
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

          result = Order.new(order).search_text
          assert_includes(result, 'Ben')
          assert_includes(result, 'Crouse')
          assert_includes(result, '22 S. 3rd St.')
          assert_includes(result, 'Philadelphia')
          assert_includes(result, 'PA')
          assert_includes(result, '19106')
          assert_includes(result, 'US')
          assert_includes(result, '2159251800')
        end

        def test_updated_at
          order = Workarea::Order.new(updated_at: Time.current)

          result = Order.new(order).updated_at
          assert_equal(order.updated_at.to_i, result.to_i)

          payment = Payment.find_or_create_by(id: order.id)
          fulfillment = Fulfillment.find_or_create_by(id: order.id)

          fulfillment.touch
          result = Order.new(order).updated_at
          assert_equal(fulfillment.updated_at.to_i, result.to_i)

          payment.touch
          result = Order.new(order).updated_at
          assert_equal(payment.updated_at.to_i, result.to_i)
        end

        def test_should_be_indexed
          order = create_order
          refute(Admin::Order.new(order).should_be_indexed?)

          order = create_order.tap(&:touch_checkout!)
          refute(Admin::Order.new(order).should_be_indexed?)

          order = create_placed_order
          assert(Admin::Order.new(order).should_be_indexed?)
        end
      end
    end
  end
end
