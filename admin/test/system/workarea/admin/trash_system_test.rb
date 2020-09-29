require 'test_helper'

module Workarea
  module Admin
    class TrashSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_restoring_from_trash
        category = create_category(name: 'My Category')

        visit admin.catalog_category_path(category)
        click_link t('workarea.admin.catalog_categories.show.delete')

        visit admin.trash_index_path
        assert(page.has_content?('My Category'))

        click_link t('workarea.admin.activities.restore')
        assert_current_path(admin.catalog_category_path(category))
        assert(page.has_content?('Success'))
        assert(page.has_content?('My Category'))

        visit admin.trash_index_path
        refute_text('My Category')
      end

      def test_restore_permission
        user = create_user(
          email: 'test@workarea.com',
          admin: true,
          catalog_access: true,
          can_restore: false
        )
        set_current_user(user)

        category = create_category(name: 'My Category')

        visit admin.catalog_category_path(category)
        click_link t('workarea.admin.catalog_categories.show.delete')

        visit admin.trash_index_path
        assert(page.has_no_content?(t('workarea.admin.activities.restore')))

        user.update_attributes(can_restore: true)

        visit admin.trash_index_path

        click_link t('workarea.admin.activities.restore')
        assert_current_path(admin.catalog_category_path(category))
        assert(page.has_content?('Success'))
      end
    end
  end
end
