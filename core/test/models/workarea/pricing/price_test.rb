require 'test_helper'

module Workarea
  module Pricing
    class PriceTest < TestCase
      def sku
        @sku ||= Sku.new(id: 'SKU')
      end

      def test_validation_callback
        price = sku.prices.build(regular: nil)
        price.valid?
        assert_equal(0.to_m, price.regular)
      end

      def test_sell
        assert_equal(4.to_m, sku.prices.build(regular: 4).sell)

        sku.on_sale = true
        price = sku.prices.build(regular: 4, sale: 3)
        assert_equal(3.to_m, price.sell)

        sku.on_sale = false
        price = sku.prices.build(regular: 4)
        assert_equal(4.to_m, price.sell)
      end

      def test_generic
        price = Price.new
        assert(price.generic?)

        price.min_quantity = 2
        refute(price.generic?)
      end

      def test_on_sale
        price = sku.prices.build
        refute(price.on_sale?)

        sku.on_sale = true
        price.on_sale = true
        assert(price.on_sale?)

        sku.on_sale = true
        price.on_sale = false
        assert(price.on_sale?)

        sku.on_sale = false
        price.on_sale = true
        assert(price.on_sale?)

        sku.on_sale = false
        price.on_sale = false
        refute(price.on_sale?)
      end

      def test_unsupported_segmentation
        price = Price.new(active_segment_ids: %w(foo bar))
        refute(price.valid?)
        assert_includes(
          price.errors[:active_segment_ids],
          t('workarea.errors.messages.unsupported_segmentation')
        )
      end
    end
  end
end
