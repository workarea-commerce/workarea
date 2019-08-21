require 'test_helper'

module Workarea
  module Admin
    class PublishingIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_publishing
        product = create_product(name: 'Foo')
        release = create_release

        patch admin.catalog_product_path(product),
          params: {
            publishing: release.id,
            product: { name: 'Bar' }
          }

        assert_nil(Release.current)
        assert_equal(release.id, session[:release_id])
        assert_equal('Foo', product.reload.name)
        assert_equal(1, product.changesets.length)

        patch admin.catalog_product_path(product),
          params: {
            publishing: 'now',
            product: { name: 'Baz' }
          }

        assert_nil(Release.current)
        assert(session[:release_id].blank?)
        assert_equal('Baz', product.reload.name)
        assert_equal(1, product.changesets.length)
      end
    end
  end
end
