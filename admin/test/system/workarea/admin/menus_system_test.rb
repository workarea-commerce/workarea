require 'test_helper'

module Workarea
  module Admin
    class MenusSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_management
        create_taxon(name: 'Foo')
        visit admin.navigation_menus_path
        click_link 'Add a menu'

        fill_in 'menu[name]', with: 'Foo'
        select 'Foo', from: 'menu[taxon_id]'
        click_button 'create_menu'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Foo'))

        click_link 'add_new_block'
        click_link 'HTML'

        fill_in 'block[data][html]', with: '<h1>Some Content!</h1>'
        click_button 'create_block'

        assert(page.has_content?('Success'))

        visit admin.navigation_menus_path

        find('.navigation-builder__node-link').hover
        within('.navigation-builder__actions') { click_link 'Edit' }
        fill_in 'menu[name]', with: 'Bar Baz'
        click_button 'save_menu'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Bar Baz'))

        find('.navigation-builder__node-link').hover
        within('.navigation-builder__actions') { click_link 'Delete' }

        assert(page.has_content?('Success'))
        refute_text('Foo')
      end

      def test_managing_content_redirects_back
        menu = create_menu

        visit admin.navigation_menus_path(menu_id: menu.id)

        click_link 'add_new_block'
        click_link 'HTML'

        fill_in 'block[data][html]', with: '<h1>Some Content!</h1>'
        click_button 'create_block'

        assert_text('Success')
        assert_text('Primary Navigation')
      end

      def test_sorting
        create_menu(name: 'Foo')
        create_menu(name: 'Bar')
        create_menu(name: 'Baz')

        visit admin.navigation_menus_path
        assert(page.has_selector?('.ui-sortable'))
      end

      def test_orders_sorting
        3.times { create_menu }
        visit admin.navigation_menus_path
        find('a', text: 'sort by orders').hover
        click_link 'Looks good, update the order'
        assert(page.has_content?('Success'))
      end

      def test_switching_active_menu
        create_menu(name: 'Foo')
        create_menu(name: 'Bar')

        visit admin.navigation_menus_path
        assert(page.has_ordered_text?('Foo', 'Bar'))

        selected_node = page.find('.navigation-builder__node--selected')
        assert(selected_node.has_content?('Foo'))

        click_link('Bar')

        selected_node = page.find('.navigation-builder__node--selected')
        assert(selected_node.has_content?('Bar'))
      end
    end
  end
end
