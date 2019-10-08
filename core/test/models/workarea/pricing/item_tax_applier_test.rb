require 'test_helper'

module Workarea
  module Pricing
    class ItemTaxApplierTest < TestCase
      setup :set_models

      def set_models
        @item = Order::Item.new
        @address = Workarea::Address.new(factory_defaults_config.billing_address)

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

      def test_adds_a_tax_price_adjustment_to_an_item
        create_tax_category(code: '101')

        applier = ItemTaxApplier.new(@address, @adjustments_to_tax)
        applier.apply

        price_adjustment = @item.price_adjustments.last
        assert_equal('tax', price_adjustment.price)
        assert_equal(0.3.to_m, price_adjustment.amount)
      end

      def test_guards_against_negative_tax_amounts
        create_tax_category(
          code: '101',
          rates: [{ percentage: -0.06, country: 'US', region: 'PA' }]
        )

        applier = ItemTaxApplier.new(@address, @adjustments_to_tax)
        applier.apply

        assert_equal(1, @item.price_adjustments.size)
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

        applier = ItemTaxApplier.new(@address, @adjustments_to_tax)
        applier.apply


        assert_equal(3, @item.price_adjustments.size)
        assert_equal(0.28.to_m, @item.price_adjustments.last.amount)

        assert_equal(2, item_2.price_adjustments.size)
        assert_equal(0.50.to_m, item_2.price_adjustments.last.amount)
      end
    end
  end
end
