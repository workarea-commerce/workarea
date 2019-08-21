require 'test_helper'

module Workarea
  module Admin
    class FeaturedProductsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_adding_a_product
        product = create_product
        category = create_category(product_ids: [])
        post admin.add_featured_product_path(category.to_global_id),
              params: { product_id: product.id }

        assert_equal([product.id], category.reload.product_ids)
      end

      def test_adding_a_product_without_publishing_authorization
        product = create_product
        category = create_category(product_ids: [])

        set_current_user(create_user(
                           admin: true,
                           releases_access: true,
                           catalog_access: true,
                           can_publish_now: false
        ))

        post admin.add_featured_product_path(category.to_global_id),
              params: { product_id: product.id },
              headers: { 'HTTP_REFERER' => admin.featured_product_path(category.to_global_id) }


        assert_equal([], category.reload.product_ids)
        assert_redirected_to(admin.featured_product_path(category.to_global_id))
        assert_equal(flash[:error], I18n.t('workarea.admin.publish_authorization.unauthorized'))

        category.update_attributes!(active: false)

        post admin.add_featured_product_path(category.to_global_id),
              params: { product_id: product.id }

        assert_equal([product.id], category.reload.product_ids)
      end

      def test_removing_a_product
        product = create_product
        category = create_category(product_ids: [product.id])
        delete admin.remove_featured_product_path(category.to_global_id),
                params: { product_id: product.id }

        assert_equal([], category.reload.product_ids)
      end
    end
  end
end
