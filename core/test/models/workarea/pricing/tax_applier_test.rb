require 'test_helper'

module Workarea
  module Pricing
    class TaxApplierTest < TestCase
      setup :set_models

      def set_models
        @shipping = create_shipping(
          address: {
            first_name: 'Ben',
            last_name: 'Crouse',
            street: '22 S. 3rd St.',
            street_2: 'Second Floor',
            city: 'Philadelphia',
            region: 'PA',
            postal_code: '19106',
            country: 'US',
            phone_number: '2159251800'
          }
        )

        @item = Order::Item.new

        @adjustments_to_tax = PriceAdjustmentSet.new(
          [
            @item.price_adjustments.build(
              price: 'item',
              amount: 5.to_m,
              data: { 'tax_code' => 101 }
            )
          ]
        )
      end

      def test_adds_a_tax_price_adjustment_to_a_shipping_item
        create_tax_category(code: '101')

        applier = TaxApplier.new(@shipping, @adjustments_to_tax)
        applier.apply
        @shipping.save!

        @shipping.reload
        price_adjustment = @shipping.price_adjustments.last
        assert_equal('tax', price_adjustment.price)
        assert_equal(0.3.to_m, price_adjustment.amount)
      end

      def test_guards_against_negative_tax_amounts
        create_tax_category(
          code: '101',
          rates: [{ percentage: -0.06, country: 'US', region: 'PA' }]
        )

        applier = TaxApplier.new(@shipping, @adjustments_to_tax)
        applier.apply
        @shipping.save!

        @shipping.reload
        assert(@shipping.price_adjustments.empty?)
      end

      def test_with_multiple_tax_codes_and_discount
        create_tax_category(
          code: '101',
          rates: [{ percentage: 0.07, country: 'US', region: 'PA' }]
        )

        create_tax_category(
          code: '102',
          rates: [{ percentage: 0.05, country: 'US', region: 'PA' }]
        )

        item_2 = Order::Item.new
        @adjustments_to_tax.concat([
          @item.price_adjustments.build(
            price: 'item',
            amount: -1.to_m,
            data: { 'discount_value' => 1.to_m }
          ),
          item_2.price_adjustments.build(
            price: 'item',
            amount: 10.to_m,
            data: { 'tax_code' => 102 }
          )
        ])

        applier = TaxApplier.new(@shipping, @adjustments_to_tax)
        applier.apply
        @shipping.save!

        @shipping.reload

        assert_equal(2, @shipping.price_adjustments.count)
        assert_equal([0.28.to_m, 0.50.to_m], @shipping.price_adjustments.map(&:amount))
      end

      def test_partial_shipping_quantity_tax_calculation
        create_tax_category(code: '101')
        @item.quantity = 2

        item_two = Order::Item.new
        @adjustments_to_tax.concat([
          item_two.price_adjustments.build(
            price: 'item',
            amount: 3.to_m,
            data: { 'tax_code' => 101 }
          )
        ])

        @shipping.update_attributes!(quantities: { @item.id => 1 })

        applier = TaxApplier.new(@shipping, @adjustments_to_tax)
        applier.apply
        @shipping.save!

        @shipping.reload
        assert_equal(1, @shipping.price_adjustments.count)
        price_adjustment = @shipping.price_adjustments.last
        assert_equal('tax', price_adjustment.price)
        assert_equal(0.15.to_m, price_adjustment.amount)
      end
    end
  end
end
