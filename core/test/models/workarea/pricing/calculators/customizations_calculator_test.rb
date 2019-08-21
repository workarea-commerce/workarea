require 'test_helper'

module Workarea
  module Pricing
    module Calculators
      class CustomizationsCalculatorTest < TestCase
        def test_adjust
          create_pricing_sku(id: 'SKU', prices: [{ regular: 5.to_m }])
          create_pricing_sku(id: 'CUST', prices: [{ regular: 1.to_m }])

          order = Order.new
          order.add_item(
            product_id: 'PRODUCT',
            sku: 'SKU',
            quantity: 2,
            customizations: { 'pricing_sku' => 'CUST' }
          )

          CustomizationsCalculator.test_adjust(order)

          assert_equal(1, order.items.first.price_adjustments.length)
          assert_equal('item', order.items.first.price_adjustments.first.price)
          assert_equal(2.to_m, order.items.first.price_adjustments.first.amount)
        end
      end
    end
  end
end
