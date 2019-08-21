require 'test_helper'

module Workarea
  module Admin
    class PricingSkuPricesIntegrationtest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_creates_price
        sku = create_pricing_sku(prices: [])

        post admin.pricing_sku_prices_path(sku),
          params: {
            price: {
              regular: '5.00',
              sale: '3.00',
              on_sale: false,
              min_quantity: 2
            }
          }

        sku.reload
        price = sku.prices.first

        assert_equal(5.to_m, price.regular)
        assert_equal(3.to_m, price.sale)
        assert_equal(2, price.min_quantity)
        refute(price.on_sale?)


        post admin.pricing_sku_prices_path(sku),
          params: {
            price: {
              regular: '5.00',
              sale: '',
              min_quantity: 2
            }
          }

        sku.reload
        price = sku.prices.last

        assert_equal(5.to_m, price.regular)
        assert_nil(price.sale)
        assert_equal(2, price.min_quantity)
      end

      def test_updates_price
        sku = create_pricing_sku(
                on_sale: true,
                prices: [
                  { regular: 3, sale: 1, min_quantity: 1, on_sale: false }
                ]
              )

        patch admin.pricing_sku_price_path(sku, sku.prices.first.id),
          params: {
            price: {
              regular: '5.00',
              sale: '',
              min_quantity: 2,
              on_sale: true
            }
          }

        sku.reload
        price = sku.prices.first

        assert_equal(5.to_m, price.regular)
        assert_nil(price.sale)
        assert_equal(2, price.min_quantity)
        assert(price.on_sale?)
      end

      def test_destroy_price
        sku = create_pricing_sku(
                prices: [{ regular: 3, sale: 1, min_quantity: 1}]
              )

        delete admin.pricing_sku_price_path(sku, sku.prices.first.id)

        sku.reload
        assert(sku.prices.empty?)
      end
    end
  end
end
