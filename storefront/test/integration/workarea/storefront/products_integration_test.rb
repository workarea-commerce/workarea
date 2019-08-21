require 'test_helper'

module Workarea
  module Storefront
    class ProductsIntegrationTest < Workarea::IntegrationTest
      def test_does_not_show_an_inactive_product
        assert_raise InvalidDisplay do
          get storefront.product_path(create_product(active: false))
          assert(response.not_found?)
        end
      end

      def test_allows_showing_an_inactive_product_when_admin_user
        set_current_user(create_user(admin: true))

        get storefront.product_path(create_product(active: false))
        assert(response.ok?)
      end

      def test_rendering_via_params
        category = create_category
        product = create_product

        Workarea.config.product_templates.each do |template|
          product.update_attributes!(template: template)

          get storefront.product_path(product, via: category.to_gid_param)
          assert_select(
            'form.product-details__add-to-cart-form input[name="via"][value=?]',
            category.to_gid_param
          )
        end
      end
    end
  end
end
