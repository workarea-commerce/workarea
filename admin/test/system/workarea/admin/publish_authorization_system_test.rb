require 'test_helper'

module Workarea
  module Admin
    class PublishAuthorizationSystemTest < Workarea::SystemTest
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

      def test_user_cannot_select_publish_now_in_workflows
        create_release(name: 'Publishing Test')
        create_product(name: 'Foo')
        create_product(name: 'Bar')

        visit admin.catalog_categories_path

        click_link 'Add New Category'
        fill_in 'category[name]', with: 'Test Category'
        click_button 'save_setup'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Products'))

        click_link t('workarea.admin.create_catalog_categories.products.pick_products')

        click_link 'Foo'
        assert(page.has_content?('Success'))

        click_link t('workarea.admin.create_catalog_categories.rules.continue_to_content')

        assert(page.has_content?('Content'))

        click_link 'add_new_block'
        click_link 'HTML'
        fill_in 'block[data][html]', with: 'Foo Bar!'
        click_button 'create_block'

        within_frame 'content-blocks' do
          assert(page.has_content?('Foo Bar!'))
        end

        assert(page.has_content?('Success'))
        click_link t('workarea.admin.create_catalog_categories.content.continue_to_taxonomy')

        click_button 'save_taxonomy'
        click_button 'save_navigation'

        assert(page.has_content?(t('workarea.admin.create_catalog_categories.publish.title', category_name: 'Test Category')))
        assert(page.has_no_content?(t('workarea.admin.create_catalog_categories.publish.now_label')))

        choose 'Publishing Test'

        click_button 'publish'
        assert(page.has_content?('Success'))
        assert(page.has_content?('Test Category'))
      end

      def test_user_cannot_submit_form_without_selecting_a_release
        release = create_release(name: 'Birthday')
        category = create_category

        visit admin.edit_catalog_category_path(category)
        assert(page.has_content?(t('workarea.admin.shared.publishing_select.warning_message')))
        assert(page.has_css?('button[disabled]'))

        select t('workarea.admin.releases.select.publish_with', release: release.name), from: :publishing
        assert(page.has_no_content?(t('workarea.admin.shared.publishing_select.warning_message')))
        assert(page.has_no_css?('button[disabled]'))

        click_button 'save_category'
        assert_current_path(admin.catalog_category_path(category))
        assert(page.has_content?('Success'))
      end
    end
  end
end
