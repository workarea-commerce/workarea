require 'test_helper'

module Workarea
  module Admin
    class HelpSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_a_help_admin_can_manage_help_articles
        admin_user = create_user(admin: true, help_admin: false)
        set_current_user(admin_user)

        visit admin.help_index_path
        assert(page.has_no_content?('Add New Article'))

        admin_user.update_attributes!(help_admin: true)

        visit admin.help_index_path
        click_link 'Add New Article'

        assert_current_path(admin.new_help_path)
        fill_in 'help_article[name]', with: 'Foo'
        fill_in 'help_article[category]', with: 'Howto'
        click_button 'create_help_article'

        assert_current_path(admin.help_index_path)
        assert(page.has_content?('Success'))
        assert(page.has_content?('Foo'))

        fill_in 'search_help', with: 'foo'
        click_button 'search_help'
        assert_current_path(/#{admin.help_index_path}/i)
        assert(page.has_content?('Foo'))
        click_link 'Edit', match: :first

        fill_in 'help_article[name]', with: 'Foo Bar'
        click_button 'save_help_article'

        article = Workarea::Help::Article.last
        assert_current_path(admin.help_path(article))
        assert(page.has_content?('Success'))
        assert(page.has_content?('Foo Bar'))
        click_button 'Delete', match: :first

        assert_current_path(admin.help_index_path)
        assert(page.has_content?('Success'))
        assert(page.has_no_content?('Foo Bar'))
      end

      def test_a_help_admin_can_manage_help_assets
        visit admin.help_assets_path
        attach_file 'help_asset[file]', product_image_file_path
        click_button 'save_help_asset'

        assert_current_path(admin.help_assets_path)
        assert(page.has_content?('Success'))
      end

      def test_a_user_can_search_help
        visit admin.help_index_path
        click_link 'Add New Article'

        assert_current_path(admin.new_help_path)
        fill_in 'help_article[name]', with: 'Foo'
        fill_in 'help_article[category]', with: 'Howto'
        click_button 'create_help_article'

        assert_current_path(admin.help_index_path)
        assert(page.has_content?('Success'))
        assert(page.has_content?('Foo'))

        click_link 'Add New Article'

        assert_current_path(admin.new_help_path)
        fill_in 'help_article[name]', with: 'Bar'
        fill_in 'help_article[category]', with: 'Howto'
        click_button 'create_help_article'

        assert_current_path(admin.help_index_path)
        assert(page.has_content?('Success'))
        assert(page.has_content?('Foo'))
        assert(page.has_content?('Bar'))

        assert(page.has_content?('Howto'))

        fill_in 'search_help', with: 'foo'
        click_button 'search_help'

        assert(page.has_content?('Foo'))

        assert(page.has_no_content?('Bar'))

        click_link 'Add New Article'
        fill_in 'help_article[name]', with: 'Footures'
        fill_in 'help_article[category]', with: 'Features'
        click_button 'create_help_article'

        click_link 'Features', match: :first
        assert(page.has_content?('1 Article'))
        assert(page.has_content?('Footures'))
        assert(page.has_no_content?('Howto'))
      end
    end
  end
end
