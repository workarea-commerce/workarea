require 'test_helper'

module Workarea
  module Pricing
    module Calculators
      class TaxCalculatorTest < TestCase
        def test_assign_item_tax
          create_pricing_sku(
            id: 'SKU',
            tax_code: '001',
            prices: [{ regular: 5.to_m }]
          )

          create_tax_category(
            code:  '001',
            rates: [{ percentage: 0.06, region: 'PA', country: 'US' }]
          )

          order = Order.new(
            items: [
              {
                price_adjustments: [
                  {
                    price: 'item',
                    amount: 5.to_m,
                    data: { 'tax_code' => '001' }
                  }
                ]
              }
            ]
          )

          shipping = Shipping.new

          shipping.set_address(
            postal_code: '19106',
            region: 'PA',
            country: 'US'
          )

          TaxCalculator.test_adjust(order, shipping)

          assert_equal(1, shipping.price_adjustments.length)
          assert_equal('tax', shipping.price_adjustments.last.price)
          assert_equal(0.30.to_m, shipping.price_adjustments.first.amount)
        end

        def test_assign_shipping_tax
          create_tax_category(
            code: '001',
            rates: [
              { percentage: 0.06,
                region: 'PA',
                country: 'US',
                charge_on_shipping: true
              }
            ]
          )

          order = Order.new
          shipping = Shipping.new

          shipping.set_shipping_service(
            id: 'GROUND',
            name: 'Ground',
            base_price: 3.to_m,
            tax_code: '001'
          )

          shipping.set_address(
            country: 'US',
            region: 'PA',
            postal_code: '19106'
          )

          TaxCalculator.test_adjust(order, shipping)

          assert_equal(2, shipping.price_adjustments.length)
          assert_equal('tax', shipping.price_adjustments.last.price)
          assert_equal(0.18.to_m, shipping.price_adjustments.last.amount)
        end

        def test_assign_shipping_tax_when_tax_does_not_charge_on_shipping
          create_tax_category(
            code: '001',
            rates: [
              { percentage: 0.06,
                region: 'PA',
                country: 'US',
                charge_on_shipping: false
              }
            ]
          )

          shipping = Shipping.new

          shipping.set_shipping_service(
            id: 'GROUND',
            name: 'Ground',
            tax_code: '001',
            base_price: 3.to_m
          )

          shipping.set_address(
            country: 'US',
            region: 'PA',
            postal_code: '19106'
          )

          TaxCalculator.test_adjust(Order.new, shipping)

          assert_equal(1, shipping.price_adjustments.length)
          assert_equal('shipping', shipping.price_adjustments.last.price)
        end

        def test_assign_tax_to_item_with_no_shipping_required
          create_pricing_sku(
            id: 'SKU',
            tax_code: '001',
            prices: [{ regular: 5.to_m }]
          )

          create_tax_category(
            code:  '001',
            rates: [{ percentage: 0.06, region: 'PA', country: 'US' }]
          )

          order = Order.new(
            items: [
              {
                fulfillment: 'download',
                price_adjustments: [
                  {
                    price: 'item',
                    amount: 5.to_m,
                    data: { 'tax_code' => '001' }
                  }
                ]
              }
            ]
          )

          payment = create_payment(
            id: order.id,
            address: factory_defaults_config.billing_address
          )

          TaxCalculator.test_adjust(order)

          item = order.items.first
          assert_equal(2, item.price_adjustments.length)
          assert_equal('tax', item.price_adjustments.last.price)
          assert_equal(0.30.to_m, item.price_adjustments.last.amount)
        end
      end
    end
  end
end
