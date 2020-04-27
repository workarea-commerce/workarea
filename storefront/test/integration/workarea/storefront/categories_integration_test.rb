require 'test_helper'

module Workarea
  module Storefront
    class CategoriesIntegrationTest < Workarea::IntegrationTest
      def test_does_not_show_inactive_category
        assert_raise InvalidDisplay do
          get storefront.category_path(create_category(active: false))
          assert(response.not_found?)
        end
      end

      def test_allows_showing_an_inactive_category_when_admin_user
        set_current_user(create_user(admin: true))

        get storefront.category_path(create_category(active: false))
        assert(response.ok?)
      end

      def test_not_accepting_per_page_param
        products = [create_product, create_product]
        category = create_category(product_ids: products.map(&:id))

        get storefront.category_path(category, page: 1, per_page: 1)
        assert(response.ok?)
        assert_includes(response.body, storefront.product_path(products.first))
        assert_includes(response.body, storefront.product_path(products.second))
      end
    end
  end
end
