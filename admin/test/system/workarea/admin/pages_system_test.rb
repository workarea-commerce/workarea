require 'test_helper'

module Workarea
  module Admin
    class PagesSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_management
        visit admin.content_pages_path

        click_link 'add_page'
        fill_in 'page[name]', with: 'Testing Page'
        click_button 'save_setup'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Content'))

        click_link 'Continue to Taxonomy'
        assert(page.has_content?('Taxonomy'))
        click_button 'save_taxonomy'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Taxonomy'))

        assert(page.has_content?('navigation'))
        click_button 'save_navigation'
        assert(page.has_content?('Success'))

        click_button 'publish'
        assert(page.has_content?('Success'))
        assert(page.has_content?('Testing Page'))

        click_link 'Attributes'
        fill_in 'page[name]', with: 'Edited Page'
        click_button 'save_page'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Edited Page'))

        click_link 'Delete'
        assert_current_path(admin.content_pages_path)
        assert(page.has_no_content?('Edited Page'))
      end

      def test_searching_pages
        create_page(name: 'Foo Page')
        visit admin.content_pages_path

        within '#page_search_form' do
          fill_in 'q', with: 'foo'
          click_button 'search_pages'
        end

        assert(page.has_content?('Foo Page'))
      end
    end
  end
end
