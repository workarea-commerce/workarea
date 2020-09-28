require 'test_helper'

module Workarea
  module Admin
    class BookmarksSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_bookmarks
        visit admin.root_path

        find('#shortcuts_menu').hover
        click_link 'Current Page'

        assert_current_path(admin.root_path)
        assert(page.has_content?('Success'))

        find('.message__dismiss-button').click
        find('#shortcuts_menu').hover
        refute_text('Current Page')

        find('#shortcuts_menu').hover
        menu_item = all('.menu__item').last
        menu_item.hover
        find('.menu__delete-link').click
        assert_current_path(admin.root_path)
        assert(page.has_content?('Success'))
        refute_text('Current Page')
      end
    end
  end
end
