require 'test_helper'

module Workarea
  module Pricing
    class SkuTest < TestCase
      setup :configure_locales
      teardown :reset_locales

      def test_validations
        sku = Sku.new(id: 'SKU')
        sku.prices.build(regular: 5.to_m, min_quantity: 2)
        refute(sku.valid?)

        sku.prices.build(regular: 5.to_m, min_quantity: 1)
        assert(sku.valid?)
      end

      def test_find_price
        sku = Sku.new(id: 'SKU')
        sku.prices.build(min_quantity: 1, regular: 1.50)
        sku.prices.build(min_quantity: 5, regular: 1.25)

        assert_equal(1.25.to_m, sku.find_price(quantity: 5).regular)
      end

      def test_active_prices
        sku = create_pricing_sku
        price = sku.prices.create!(regular: 1.to_m)

        I18n.for_each_locale do |locale|
          assert_includes(sku.active_prices, price, "Price not active in #{locale}")
        end
      end

      def test_unsupported_segmentation
        sku = Sku.new(active_segment_ids: %w(foo bar))
        refute(sku.valid?)
        assert_includes(
          sku.errors[:active_segment_ids],
          t('workarea.errors.messages.unsupported_segmentation')
        )
      end

      private

      def configure_locales
        @original_locales = I18n.available_locales
        I18n.available_locales << :de
      end

      def reset_locales
        I18n.available_locales = @original_locales
      end
    end
  end
end
