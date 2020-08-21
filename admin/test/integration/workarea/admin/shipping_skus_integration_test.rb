require 'test_helper'

module Workarea
  module Admin
    class ShippingSkusIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_creation
        post admin.shipping_skus_path,
          params: {
            sku: {
              id: 'SKU1',
              weight: 4,
              length: 5,
              width: 6,
              height: 7
            }
          }

        assert_redirected_to(admin.shipping_sku_path('SKU1'))
        assert_equal(1, Shipping::Sku.count)

        sku = Shipping::Sku.first
        assert_equal('SKU1', sku.id)
        assert_equal(4, sku.weight)
        assert_equal(5, sku.length)
        assert_equal(6, sku.width)
        assert_equal(7, sku.height)
      end

      def test_updating
        post admin.shipping_skus_path,
          params: {
            sku: {
              id: 'SKU1',
              weight: 4,
              length: 1,
              width: 2,
              height: 3
            }
          }

        assert_redirected_to(admin.shipping_sku_path('SKU1'))

        patch admin.shipping_sku_path('SKU1'),
          params: {
            sku: {
              weight: 5,
              length: 6,
              width: 7,
              height: 8
            }
          }

        assert_redirected_to(admin.shipping_sku_path('SKU1'))
        assert_equal(1, Shipping::Sku.count)

        sku = Shipping::Sku.first

        assert_equal('SKU1', sku.id)
        assert_equal(5, sku.weight)
        assert_equal(6, sku.length)
        assert_equal(7, sku.width)
        assert_equal(8, sku.height)
      end
    end
  end
end
