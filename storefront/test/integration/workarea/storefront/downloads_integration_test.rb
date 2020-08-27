require 'test_helper'

module Workarea
  module Storefront
    class DownloadsIntegrationTest < Workarea::IntegrationTest
      def test_show
        token = create_fulfillment_token(sku: 'SKU1')
        sku = create_fulfillment_sku(id: 'SKU1', policy: :download, file: product_image_file_path)

        get storefront.download_path(token)
        assert(response.ok?)
        assert_equal(1, token.reload.downloads)

        token.update!(enabled: false)

        get storefront.download_path(token)
        assert_redirected_to(storefront.root_path)
        assert(flash[:info].present?)
        assert_equal(1, token.reload.downloads)

        token.update!(enabled: true)
        sku.update!(policy: 'shipping')

        get storefront.download_path(token)
        assert_redirected_to(storefront.root_path)
        assert(flash[:info].present?)
        assert_equal(1, token.reload.downloads)

        sku.destroy!

        get storefront.download_path(token)
        assert_redirected_to(storefront.root_path)
        assert(flash[:info].present?)
        assert_equal(1, token.reload.downloads)
      end
    end
  end
end
