require 'test_helper'

module Workarea
  module Admin
    class PricingSkuViewModelTest < Workarea::TestCase
      setup :setup_pricing_sku_and_prices

      def setup_pricing_sku_and_prices
        @sku = PricingSkuViewModel.wrap(
          create_pricing_sku(on_sale: true).tap do |sku|
            sku.prices.create!(
              regular: 4.to_m,
              sale: 1.to_m
            )
            sku.prices.create!(
              regular: 3.to_m,
              sale: 2.to_m
            )
          end
        )
      end

      def test_sell_prices
        assert_equal(@sku.prices.count, @sku.sell_prices.count)
      end

      def test_min_price
        assert_equal(1.to_m, @sku.min_price)

        @sku.update!(on_sale: false)

        assert_equal(3.to_m, @sku.min_price)

        @sku.prices.destroy_all

        assert_nil(@sku.min_price)
      end

      def test_max_price
        assert_equal(2.to_m, @sku.max_price)

        @sku.update!(on_sale: false)

        assert_equal(4.to_m, @sku.max_price)

        @sku.prices.destroy_all

        assert_nil(@sku.min_price)
      end

      def test_show_range?
        assert(@sku.show_range?)

        @sku.prices.last.destroy!

        refute(@sku.show_range?)

        @sku.prices.destroy_all

        refute(@sku.show_range?)
      end

      def test_on_sale?
        assert(@sku.on_sale?)

        @sku.update!(on_sale: false)

        refute(@sku.on_sale?)

        @sku.prices.first.update!(on_sale: true)

        assert(@sku.on_sale?)
      end

      def test_price
        assert_match(/.2\.00 – .1\.00/, @sku.sell_price)

        @sku.update!(on_sale: false)

        assert_match(/.4\.00 – .3\.00/, @sku.sell_price)
      end
    end
  end
end
