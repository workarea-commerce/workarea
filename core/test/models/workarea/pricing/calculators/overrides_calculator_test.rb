require 'test_helper'

module Workarea
  module Pricing
    module Calculators
      class OverridesCalculatorTest < TestCase
        setup :set_order, :override

        def set_order
          create_pricing_sku(id: 'SKU1', prices: [{ regular: 5.to_m }])
          create_pricing_sku(id: 'SKU2', prices: [{ regular: 20.to_m }])

          @order = Order.new
          @order.add_item(product_id: 'PRODUCT', sku: 'SKU1', quantity: 2)
          @order.add_item(product_id: 'PRODUCT', sku: 'SKU2', quantity: 1)

          ItemCalculator.test_adjust(@order) # set the unit price adjustments
        end

        def override
          @override ||= Override.find_or_create_by!(id: @order.id)
        end

        def test_adjusting_total_for_items
          override.update_attributes!(
            item_prices: {
              @order.items.first.id.to_s => 6.0, # increasing price
              @order.items.second.id.to_s => 15.0
            }
          )

          OverridesCalculator.test_adjust(@order)

          assert_equal(2, @order.items.first.price_adjustments.length)
          assert_equal('item', @order.items.first.price_adjustments.last.price)
          assert_equal(2.to_m, @order.items.first.price_adjustments.last.amount)

          assert_equal(2, @order.items.second.price_adjustments.length)
          assert_equal('item', @order.items.second.price_adjustments.last.price)
          assert_equal(-5.to_m, @order.items.second.price_adjustments.last.amount)
        end

        def test_adjusting_subtotal
          override.update_attributes!(
            item_prices: {
              @order.items.first.id.to_s => 6.0,
              @order.items.second.id.to_s => 7.5
            },
            subtotal_adjustment: -12.to_m
          )

          OverridesCalculator.test_adjust(@order)

          assert_equal(2, @order.items.first.price_adjustments.length)
          assert_equal('order', @order.items.first.price_adjustments.last.price)
          assert_equal(-4.to_m, @order.items.first.price_adjustments.last.amount)

          assert_equal(2, @order.items.second.price_adjustments.length)
          assert_equal('order', @order.items.second.price_adjustments.last.price)
          assert_equal(-8.to_m, @order.items.second.price_adjustments.last.amount)
        end

        def test_adjusting_shipping
          override.update_attributes!(
            subtotal_adjustment: -12.to_m,
            shipping_adjustment: -3.to_m,
          )

          shippings = [
            Shipping.create!(
              order_id: @order.id,
              price_adjustments: [{ price: 'shipping', amount: 5.to_m, calculator: 'Workarea::Shipping' }]
            ),
            Shipping.create!(
              order_id: @order.id,
              price_adjustments: [{ price: 'shipping', amount: 10.to_m, calculator: 'Workarea::Shipping' }]
            )
          ]

          # Will add to price
          OverridesCalculator.test_adjust(@order, shippings.first)

          assert_equal(2, shippings.first.price_adjustments.length)
          assert_equal('shipping', shippings.first.price_adjustments.last.price)
          assert_equal(-3.to_m, shippings.first.price_adjustments.last.amount)

          shippings.first.reset_adjusted_shipping_pricing
          OverridesCalculator.test_adjust(@order, shippings)

          assert_equal(2, shippings.first.price_adjustments.length)
          assert_equal('shipping', shippings.first.price_adjustments.last.price)
          assert_equal(-1.to_m, shippings.first.price_adjustments.last.amount)

          assert_equal(2, shippings.second.price_adjustments.length)
          assert_equal('shipping', shippings.second.price_adjustments.last.price)
          assert_equal(-2.to_m, shippings.second.price_adjustments.last.amount)
        end

        def test_negative_prices
          override.update_attributes!(
            item_prices: {
              @order.items.first.id.to_s => -1.0,
              @order.items.second.id.to_s => -5.0
            },
            shipping_adjustment: -10.to_m
          )

          shipping = Shipping.create!(
            order_id: @order.id,
            price_adjustments: [{ price: 'shipping', amount: 5.to_m, calculator: 'Workarea::Shipping' }]
          )

          OverridesCalculator.test_adjust(@order, shipping)

          assert_equal(2, @order.items.first.price_adjustments.length)
          assert_equal('item', @order.items.first.price_adjustments.last.price)
          assert_equal(-10.to_m, @order.items.first.price_adjustments.last.amount)

          assert_equal(2, @order.items.second.price_adjustments.length)
          assert_equal('item', @order.items.second.price_adjustments.last.price)
          assert_equal(-20.to_m, @order.items.second.price_adjustments.last.amount)

          assert_equal(2, shipping.price_adjustments.length)
          assert_equal('shipping', shipping.price_adjustments.last.price)
          assert_equal(-5.to_m, shipping.price_adjustments.last.amount)
        end
      end
    end
  end
end
