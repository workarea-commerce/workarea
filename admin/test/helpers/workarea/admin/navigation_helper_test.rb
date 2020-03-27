require 'test_helper'

module Workarea
  module Admin
    class NavigationHelperTest < ViewTest
      include Engine.routes.url_helpers

      def test_index_url_for
        assert_equal(admin.catalog_products_path, index_url_for(Catalog::Product))
        assert_equal(admin.catalog_products_path, index_url_for(create_product))
        assert_nil(index_url_for(Fulfillment))
        assert_raises { index_url_for('foo') }
      end
    end
  end
end
