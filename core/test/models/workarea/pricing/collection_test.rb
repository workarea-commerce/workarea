require 'test_helper'

module Workarea
  module Pricing
    class CollectionTest < TestCase
      def test_on_sale?
        refute(Collection.new([]).on_sale?)

        create_pricing_sku(
          id: 'SKU1',
          prices: [{ regular: 5.to_m }]
        )

        refute(Collection.new('SKU1').on_sale?)

        create_pricing_sku(
          id: 'SKU2',
          on_sale: true,
          prices: [{ regular: 5.to_m }]
        )

        assert(Collection.new(%w(SKU1 SKU2)).on_sale?)
      end

      def test_has_prices?
        refute(Collection.new(['SKU']).has_prices?)

        create_pricing_sku(id: 'SKU1', on_sale: true, prices: [{ regular: 5.to_m }])
        assert(Collection.new(['SKU1', 'SKU2']).has_prices?)
      end

      def test_on_sale?
        create_pricing_sku(id: 'SKU1', on_sale: true, prices: [{ regular: 5.to_m }])
        create_pricing_sku(id: 'SKU2', on_sale: false, prices: [{ regular: 6.to_m }])
        create_pricing_sku(id: 'SKU3', prices: [{ regular: 7.to_m }])

        assert(Collection.new(%w(SKU1 SKU2 SKU3)).on_sale?)
      end

      def test_regular_min_price
        create_pricing_sku(id: 'SKU1', prices: [{ regular: 4.to_m }, { regular: 5.to_m }])
        create_pricing_sku(id: 'SKU2', prices: [{ regular: 6.to_m }])
        assert_equal(4.to_m, Collection.new(%w(SKU1 SKU2)).regular_min_price)
      end

      def test_regular_max_price
        create_pricing_sku(id: 'SKU1', prices: [{ regular: 5.to_m }])
        create_pricing_sku(id: 'SKU2', prices: [{ regular: 6.to_m }])
        assert_equal(6.to_m, Collection.new(%w(SKU1 SKU2)).regular_max_price)
      end

      def test_sale_min_price
        create_pricing_sku(id: 'SKU1', prices: [{ regular: 1.to_m, sale: 3.to_m }])
        create_pricing_sku(id: 'SKU2', prices: [{ regular: 2.to_m, sale: 4.to_m }])
        create_pricing_sku(id: 'SKU3', prices: [{ regular: 3.to_m }])

        assert_equal(3.to_m, Collection.new(%w(SKU1 SKU2 SKU3)).sale_min_price)
      end

      def test_sale_max_price
        create_pricing_sku(id: 'SKU1', prices: [{ regular: 1.to_m, sale: 3.to_m }])
        create_pricing_sku(id: 'SKU2', prices: [{ regular: 2.to_m, sale: 4.to_m }])
        create_pricing_sku(id: 'SKU3', prices: [{ regular: 3.to_m }])

        assert_equal(4.to_m, Collection.new(%w(SKU1 SKU2 SKU3)).sale_max_price)
      end

      def test_sell_min_price
        create_pricing_sku(id: 'SKU1', on_sale: true, prices: [{ regular: 1.to_m, sale: 3.to_m }])
        create_pricing_sku(id: 'SKU2', prices: [{ regular: 2.to_m, sale: 4.to_m }])
        create_pricing_sku(id: 'SKU3', prices: [{ regular: 3.to_m }])

        assert_equal(2.to_m, Collection.new(%w(SKU1 SKU2 SKU3)).sell_min_price)
      end

      def test_sell_max_price
        create_pricing_sku(id: 'SKU1', prices: [{ regular: 1.to_m, sale: 3.to_m }])
        create_pricing_sku(id: 'SKU2', on_sale: true, prices: [{ regular: 2.to_m, sale: 4.to_m }])
        create_pricing_sku(id: 'SKU3', prices: [{ regular: 3.to_m }])

        assert_equal(4.to_m, Collection.new(%w(SKU1 SKU2 SKU3)).sell_max_price)
      end

      def test_msrp_min_price
        create_pricing_sku(id: 'SKU1', msrp: 3.to_m, prices: [{ regular: 1.to_m }])
        create_pricing_sku(id: 'SKU2', msrp: 4.to_m, prices: [{ regular: 2.to_m }])
        create_pricing_sku(id: 'SKU3', prices: [{ regular: 3.to_m }])

        assert_equal(3.to_m, Collection.new(%w(SKU1 SKU2 SKU3)).msrp_min_price)
      end

      def test_msrp_max_price
        create_pricing_sku(id: 'SKU1', msrp: 3.to_m, prices: [{ regular: 1.to_m }])
        create_pricing_sku(id: 'SKU2', msrp: 4.to_m, prices: [{ regular: 2.to_m }])
        create_pricing_sku(id: 'SKU3', prices: [{ regular: 3.to_m }])

        assert_equal(4.to_m, Collection.new(%w(SKU1 SKU2 SKU3)).msrp_max_price)
      end
    end
  end
end
