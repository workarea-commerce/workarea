require 'test_helper'

module Workarea
  module Admin
    class ToolbarSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_super_admin_shows_a_admin_toolbar
        category = create_category(name: 'Foo', active: false)

        visit admin.toolbar_path(id: category.to_global_id.to_param)
        find('.header__alert-icon').hover
        assert(page.has_content?(t('workarea.admin.toolbar.inactive_message', model: 'Foo')))

        click_link t('workarea.admin.toolbar.admin_model_view', model: 'Foo')
        assert_current_path(admin.catalog_category_path(category))

        visit admin.toolbar_path(id: category.to_global_id.to_param)
        click_link t('workarea.admin.toolbar.edit_content')
        assert_current_path(admin.edit_content_path(Content.for(category)))
      end
    end
  end
end
