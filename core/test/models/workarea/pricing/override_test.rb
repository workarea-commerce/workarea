require 'test_helper'

module Workarea
  module Pricing
    class OverrideTest < TestCase
      def test_has_adjustments
        override = Pricing::Override.new(
          item_prices: {
            '1234' => 4.0,
            '5678' => 2.0
          },
          subtotal_adjustment: -12.to_m,
          shipping_adjustment: -3.to_m
        )

        assert(override.has_adjustments?)
        assert(override.adjusts_shipping?)
        assert(override.adjusts_items?)
        assert(override.adjusts_subtotal?)
      end

      def test_adjusts_subtotal
        override = Pricing::Override.new(
          subtotal_adjustment: -12.to_m
        )

        refute(override.adjusts_shipping?)
        refute(override.adjusts_items?)
        assert(override.adjusts_subtotal?)
      end

      def test_adjusts_items
        override = Pricing::Override.new(
          item_prices: {
            '1234' => 4.0,
            '5678' => 2.0
          }
        )

        refute(override.adjusts_shipping?)
        assert(override.adjusts_items?)
        refute(override.adjusts_subtotal?)
      end

      def test_item_price_for_id
        override = Pricing::Override.new(
          item_prices: {
            '1234' => '',
            '5678' => 2.0
          }
        )

        assert_nil(override.item_price_for_id('2222'))
        assert_nil(override.item_price_for_id('1234'))
        assert_equal(2.to_m, override.item_price_for_id('5678'))
      end

      def test_handles_currency_changes
        current_default = Money.default_currency
        aud = Money::Currency.new('AUD')
        Money.default_currency = aud
        override = Pricing::Override.new

        assert_equal(aud, override.subtotal_adjustment.currency)

      ensure
        Money.default_currency = current_default
      end
    end
  end
end
