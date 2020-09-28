require 'test_helper'

module Workarea
  module Storefront
    class NavigationSystemTest < Workarea::SystemTest
      include Storefront::SystemTest
      include BreakpointHelpers
      setup :set_navigation_menu

      def set_navigation_menu
        first_level = create_taxon(
          name: 'First Level',
          url: 'http://example.com'
        )

        second_level = first_level.children.create!(
          name: 'Second Level',
          url: 'http://www.example.com'
        )

        menu = create_menu(taxon: first_level)

        content = Content.for(menu)
        content.blocks.create!(
          type: 'taxonomy',
          data: { 'start' => second_level.id }
        )
      end

      def test_desktop_navigation_menus
        visit storefront.root_path
        assert(page.has_content?('First Level'))

        find('li.primary-nav__item').hover
        assert(page.has_content?('Second Level'))
      end

      def test_mobile_navigation_menus
        resize_window_to('small')

        leaf = create_taxon(name: 'Leaf', url: 'http://example.com')
        menu = create_menu(taxon: leaf)
        content = Content.for(menu)
        content.blocks.create!(type: 'text', data: { text: 'Foo' })

        visit storefront.root_path
        click_link 'mobile_nav_button'

        click_link 'First Level'
        assert(page.has_content?('Second Level'))

        click_link '←'
        click_link 'Leaf'
        assert(page.has_content?('Foo'))
        assert_current_path(storefront.root_path)

        page.execute_script("$('body').trigger('click');")
        refute_text('Foo')
      end

      def test_left_navigation
        primary = create_taxon(navigable: create_page(show_navigation: true))
        secondary = primary.children.create!(navigable: create_category(name: 'Foo'))

        visit storefront.page_path(primary.navigable)
        assert(page.has_content?('Foo'))

        secondary.navigable.update_attributes!(active: false)
        visit storefront.page_path(primary.navigable)
        refute_text('Foo')
      end
    end
  end
end
