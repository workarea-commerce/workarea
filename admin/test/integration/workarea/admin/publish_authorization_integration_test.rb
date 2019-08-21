require 'test_helper'

module Workarea
  module Admin
    class PublishAuthorizationIntegrationTest < Workarea::IntegrationTest
      setup :set_publish_user

      def user
        create_user(
          admin: true,
          releases_access: true,
          store_access: true,
          catalog_access: true,
          search_access: true,
          orders_access: true,
          people_access: true,
          settings_access: true,
          marketing_access: true,
          can_publish_now: false
        )
      end

      def set_publish_user
        set_current_user(user)
      end

      def test_user_cannot_publish_to_live_site
        category = create_category(name: 'Foo Category')

        patch admin.catalog_category_path(category),
          params: { category: { name: 'Test Category' } },
          headers: { 'HTTP_REFERER' => admin.edit_catalog_category_path(category) }

        assert_redirected_to(admin.edit_catalog_category_path(category))
        assert_equal(flash[:error], I18n.t('workarea.admin.publish_authorization.unauthorized'))

        delete admin.catalog_category_path(category),
          headers: { 'HTTP_REFERER' => admin.catalog_category_path(category) }

        assert_redirected_to(admin.catalog_category_path(category))
        assert_equal(flash[:error], I18n.t('workarea.admin.publish_authorization.unauthorized'))
        assert(category.reload.persisted?)
      end

      def test_user_can_publish_now_within_a_release
        release = create_release
        category = create_category(name: 'Foo Category')

        patch admin.catalog_category_path(category),
          params: { publishing: release.id, category: { name: 'Test Category' } },
          headers: { 'HTTP_REFERER' => admin.edit_catalog_category_path(category) }

        assert_redirected_to(admin.catalog_category_path(category))
        assert(flash[:error].blank?)

        delete admin.catalog_category_path(category),
          params: { publishing: release.id },
          headers: { 'HTTP_REFERER' => admin.catalog_category_path(category) }

        assert_redirected_to(admin.catalog_categories_path)
        assert(flash[:error].blank?)
        assert(Catalog::Category.empty?)
      end
    end
  end
end
