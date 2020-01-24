require 'test_helper'

module Workarea
  module Admin
    class CatalogProductCopiesIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_create
        product = create_product(
          id: 'foo123',
          variants: [{ sku: 'FOO1', regular: 5.to_m }]
        )

        post admin.catalog_product_copies_path,
          params: {
            source_id: product.id,
            product: {
              active: false,
              id: 'bar345'
            }
          }

        new_product = Catalog::Product.find('bar345')

        assert_redirected_to(
          admin.edit_create_catalog_product_path(
            new_product,
            continue: true
          )
        )

        assert_equal("#{product.slug}-1", new_product.slug)
        assert_equal('FOO1', new_product.variants.first.sku)
      end
    end
  end
end
