require 'test_helper'

module Workarea
  module Admin
    class MenusIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      setup do
        @taxon = create_taxon
      end

      def test_sorting_display_during_release
        menu_one = create_menu(name: 'Foo 1', position: 1)
        menu_two = create_menu(name: 'Foo 2', position: 2)
        menu_three = create_menu(name: 'Foo 3', position: 3)

        post admin.move_navigation_menus_path,
          params: {
            positions: {
              menu_three.id => 0,
              menu_two.id => 1,
              menu_one.id => 2
            }
          }

        get admin.navigation_menus_path
        assert_match(/Foo 3.*Foo 2.*Foo 1/m, response.body)

        release = create_release

        post admin.move_navigation_menus_path,
          params: {
            publishing: release.id,
            positions: {
              menu_three.id => 2,
              menu_two.id => 1,
              menu_one.id => 0
            }
          }

        release.as_current do
          get admin.navigation_menus_path
          assert_match(/Foo 1.*Foo 2.*Foo 3/m, response.body)
        end
      end

      def test_creation
        post admin.navigation_menus_path,
          params: {
            menu: {
              name: 'New Menu',
              taxon_id: @taxon.id
            }
          }

        assert_equal(1, Navigation::Menu.count)
        menu = Navigation::Menu.first

        assert_equal('New Menu', menu.name)
        assert_equal(@taxon, menu.taxon)
      end

      def test_updates
        menu = create_menu(name: 'Foo', taxon: create_taxon)

        put admin.navigation_menu_path(menu),
          params: {
            menu: {
              name: 'New Menu',
              taxon_id: @taxon.id
            }
          }

        assert_equal(1, Navigation::Menu.count)

        menu.reload
        assert_equal('New Menu', menu.name)
        assert_equal(@taxon, menu.taxon)
      end

      def test_sorting
        menu_one = create_menu(position: 1)
        menu_two = create_menu(position: 2)
        menu_three = create_menu(position: 3)

        Metrics::MenuByDay.inc(key: { menu_id: menu_one.id }, orders: 1)
        Metrics::MenuByDay.inc(key: { menu_id: menu_two.id }, orders: 2)
        Metrics::MenuByDay.inc(key: { menu_id: menu_three.id }, orders: 3)

        post admin.sort_navigation_menus_path

        assert_equal(0, menu_three.reload.position)
        assert_equal(1, menu_two.reload.position)
        assert_equal(2, menu_one.reload.position)
      end

      def test_moving
        menu_one = create_menu(position: 1)
        menu_two = create_menu(position: 2)
        menu_three = create_menu(position: 3)

        post admin.move_navigation_menus_path,
          params: {
            positions: {
              menu_three.id => 0,
              menu_two.id => 1,
              menu_one.id => 2
            }
          }

        assert_equal(0, menu_three.reload.position)
        assert_equal(1, menu_two.reload.position)
        assert_equal(2, menu_one.reload.position)
      end

      def test_destroys
        menu = create_menu(taxon: @taxon)
        delete admin.navigation_menu_path(menu)
        assert_equal(0, Navigation::Menu.count)
      end

      def test_deactivates_menu_when_deleting_on_a_release
        menu = create_menu(taxon: @taxon)
        release = create_release

        post admin.release_session_path,
          params: { release_id: release.id }

        delete admin.navigation_menu_path(menu)

        release.as_current do
          menu.reload
          refute(menu.active?)
        end

        Release.current = nil
        menu.reload
        assert(menu.active?)
      end
    end
  end
end
