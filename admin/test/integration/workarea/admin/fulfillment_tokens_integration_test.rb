require 'test_helper'

module Workarea
  module Admin
    class FulfillmentTokensIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_create
        sku = create_fulfillment_sku(
          id: 'SKU1',
          policy: 'download',
          file: product_image_file_path
        )

        post admin.fulfillment_sku_tokens_path(sku)

        assert_equal(1, Fulfillment::Token.count)

        token = Fulfillment::Token.first
        assert_equal('SKU1', token.sku)

        assert_redirected_to(
          admin.fulfillment_sku_tokens_path(sku, new_token: token.id)
        )
      end

      def test_update
        sku = create_fulfillment_sku(id: 'SKU1')
        token = Fulfillment::Token.create!(sku: sku.id)

        patch admin.fulfillment_sku_token_path(sku, token),
          params: { token: { enabled: '0' } }

        assert_equal(1, Fulfillment::Token.count)

        assert_redirected_to(admin.fulfillment_sku_tokens_path(sku))

        token.reload
        assert(token.disabled?)
      end
    end
  end
end
