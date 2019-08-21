require 'test_helper'

module Workarea
  module Admin
    class PricingSkusIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_creation
        post admin.pricing_skus_path,
          params: {
            sku: {
              id: 'SKU1',
              tax_code: '001',
              on_sale: 'true',
              discountable: 'true',
              msrp: ''
            },
            prices: [
              { regular: '10', sale: '', min_quantity: 1 },
              { regular: '', min_quantity: 1 }
            ]
          }

        assert_equal(1, Pricing::Sku.count)

        sku = Pricing::Sku.first
        assert_equal('SKU1', sku.id)
        assert_equal('001', sku.tax_code)
        assert(sku.on_sale?)
        assert(sku.discountable?)
        assert_nil(sku.msrp)
        assert_equal(1, sku.prices.count)
        assert_equal(10.to_m, sku.prices.first.regular)
        assert_nil(sku.prices.first.sale)
      end

      def test_updating
        post admin.pricing_skus_path,
          params: {
            sku: {
              id: 'SKU1',
              tax_code: '001',
              on_sale: 'true',
              discountable: 'true'
            }
          }

        patch admin.pricing_sku_path('SKU1'),
          params: {
            sku: {
              tax_code: '002',
              on_sale: 'false',
              discountable: 'false'
            }
          }

        assert_equal(1, Pricing::Sku.count)

        sku = Pricing::Sku.first
        assert_equal('SKU1', sku.id)
        assert_equal('002', sku.tax_code)
        refute(sku.on_sale?)
        refute(sku.discountable?)
      end
    end
  end
end
