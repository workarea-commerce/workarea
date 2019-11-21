require 'test_helper'

module Workarea
  module Admin
    class FulfillmentSkusIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_create
        post admin.fulfillment_skus_path,
          params: {
            sku: {
              id: 'SKU1',
              policy: 'shipping',
            }
          }

        assert_equal(1, Fulfillment::Sku.count)
        assert_redirected_to(admin.fulfillment_sku_path('SKU1'))

        sku = Fulfillment::Sku.first
        assert_equal('SKU1', sku.id)
        assert_equal('shipping', sku.policy)
      end

      def test_update
        sku = create_fulfillment_sku(id: 'SKU1')

        patch admin.fulfillment_sku_path('SKU1'),
          params: {
            sku: {
              policy: 'download',
              file: Rack::Test::UploadedFile.new(product_image_file_path)
            }
          }

        assert_equal(1, Fulfillment::Sku.count)

        assert_redirected_to(admin.fulfillment_sku_path('SKU1'))

        sku.reload
        assert_equal('SKU1', sku.id)
        assert_equal('download', sku.policy)
        assert(sku.file_name.present?)
      end

      def test_destroy
        sku = create_fulfillment_sku(id: 'SKU1')
        delete admin.fulfillment_sku_path('SKU1')

        assert_equal(0, Fulfillment::Sku.count)
        assert_redirected_to(admin.fulfillment_skus_path)
      end
    end
  end
end
