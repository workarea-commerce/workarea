require 'test_helper'

module Workarea
  module Storefront
    class NavigationHelperTest < ViewTest
      include Storefront::Engine.routes.url_helpers
      include AnalyticsHelper

      def test_storefront_path_for
        taxon = Navigation::Taxon.new
        assert_equal(storefront.root_path, storefront_path_for(taxon))

        taxon = create_taxon(url: 'http://example.com')
        assert_equal('http://example.com', storefront_path_for(taxon))

        taxon = Navigation::SearchResults.new(q: 'foo').taxon
        assert_equal(search_path(q: 'foo'), storefront_path_for(taxon))

        product = create_product
        taxon = create_taxon(navigable: product)
        assert_equal(storefront.product_path(product.slug), storefront_path_for(taxon))
      end

      def test_mobile_nav_return_path
        params[:return_to] = 'http://example.com/foo/bar'
        assert_equal('/foo/bar', mobile_nav_return_path)
      end

      def test_taxon_cache_key
        taxon = create_taxon(name: 'parent')
        child = taxon.children.create!(name: 'child')
        section = :left_navigation
        selected = "selected:#{child.cache_key}"
        bare_cache_key = taxon_cache_key(taxon)
        section_cache_key = taxon_cache_key(taxon, section)
        child_cache_key = taxon_cache_key(taxon, section, selected: child)

        assert_includes bare_cache_key, taxon.cache_key
        refute_includes bare_cache_key, selected
        refute_includes bare_cache_key, section.to_s

        assert_includes section_cache_key, taxon.cache_key
        refute_includes section_cache_key, selected
        assert_includes section_cache_key, section.to_s

        assert_includes child_cache_key, taxon.cache_key
        assert_includes child_cache_key, selected
        assert_includes child_cache_key, section.to_s
      end

      def test_navigation_menus
        release = create_release(publish_at: 1.week.from_now, published_at: nil)
        menu_1 = Navigation::Menu.create!(taxon: create_taxon(name: 'Menu 1'))
        menu_2 = Navigation::Menu.create!(taxon: create_taxon(name: 'Menu 2'))
        menu_3 = Navigation::Menu.create!(taxon: create_taxon(name: 'Menu 3'))
        old_menu = Navigation::Menu.create!(taxon: create_taxon(name: 'Old Menu'), active: false)

        release.as_current do
          menu_1.position = nil
          old_menu.active = true
          menu_1.save!
          old_menu.save!
        end

        assert_equal [menu_1, menu_2, menu_3], navigation_menus

        release.as_current do
          # The `navigation_menus` helper is memoized, this forces the
          # helper to re-run the query within the release context
          remove_instance_variable('@navigation_menus')

          assert_equal [menu_2, menu_3, old_menu, menu_1], navigation_menus
        end
      end

      def test_link_to_menu
        linked_taxon = create_taxon(name: 'Linked Menu', url: 'http://example.com')
        unlinked_taxon = create_taxon(name: 'Unlinked Menu', url: nil)
        linked_menu = Navigation::Menu.create!(taxon: linked_taxon)
        unlinked_menu = Navigation::Menu.create!(taxon: unlinked_taxon)

        assert_match(/\A<a/, link_to_menu(linked_menu))
        assert_match(/\A<span/, link_to_menu(unlinked_menu))
        assert_match(/primary-nav__link/, link_to_menu(linked_menu))
        assert_match(/primary-nav__link/, link_to_menu(unlinked_menu))
      end
    end
  end
end
