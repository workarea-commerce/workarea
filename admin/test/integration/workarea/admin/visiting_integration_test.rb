require 'test_helper'

module Workarea
  module Admin
    class VisitingIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_visiting
        product = create_product

        get admin.root_path
        assert_equal(0, User::AdminVisit.count)

        get admin.toolbar_path
        assert_equal(0, User::AdminVisit.count)

        get admin.catalog_products_path, xhr: true
        assert_equal(0, User::AdminVisit.count)

        patch admin.catalog_product_path(product),
          params: { product: { name: 'Test Product' } }
        assert_equal(0, User::AdminVisit.count)

        get admin.catalog_products_path
        assert_equal(1, User::AdminVisit.count)

        visit = User::AdminVisit.first
        assert_equal(admin.catalog_products_path, visit.path)
        assert(visit.name.present?)

        get admin.catalog_product_path(product)
        assert_equal(2, User::AdminVisit.count)

        visit = User::AdminVisit.desc(:created_at).first
        assert_equal(admin.catalog_product_path(product), visit.path)
        assert(visit.name.present?)
      end
    end
  end
end
