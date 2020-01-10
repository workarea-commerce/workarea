require 'test_helper'

module Workarea
  module Storefront
    class ReleaseBrowsingSystemTest < Workarea::SystemTest
      def test_browsing_a_release
        set_current_user(create_user(super_admin: true))

        release = create_release(name: 'Browse Release')
        page1 = create_page(name: 'Foo')
        page2 = create_page(name: 'Bar')
        create_product(name: 'Product 1', active: true)
        product2 = create_product(name: 'Product 2', active: false)

        first_taxon = create_taxon(name: 'Example', url: 'http://example.com')
        create_menu(taxon: first_taxon)

        second_taxon = create_taxon(name: 'New Taxon', url: 'http://example.com')
        second_menu = create_menu(taxon: second_taxon, active: false)

        Release.with_current(release.id) do
          page1.update_attributes!(name: 'Foo Changed')
          page2.update_attributes!(name: 'Bar Changed')
          product2.update_attributes!(active: true)
          second_menu.update_attributes!(active: true)
        end

        visit storefront.root_path
        assert(page.has_no_content?('New Taxon'))

        page.document.synchronize do
          within_frame find('.admin-toolbar') do
            find_field 'release_id'
            select 'Browse Release', from: 'release_id'
          end
        end
        assert(page.has_content?('New Taxon'))

        visit storefront.page_path(page1)

        page.document.synchronize do
          within_frame find('.admin-toolbar') do
            find_field 'release_id'
            select 'the live site', from: 'release_id'
          end
        end
        assert(page.has_no_content?('Foo Changed'))

        page.document.synchronize do
          within_frame find('.admin-toolbar') do
            find_field 'release_id'
            select 'Browse Release', from: 'release_id'
          end
        end
        assert(page.has_content?('Foo Changed'))

        visit storefront.page_path(page2)

        page.document.synchronize do
          within_frame find('.admin-toolbar') do
            find_field 'release_id'
            select 'the live site', from: 'release_id'
          end
        end
        assert(page.has_no_content?('Bar Changed'))

        page.document.synchronize do
          within_frame find('.admin-toolbar') do
            find_field 'release_id'
            select 'Browse Release', from: 'release_id'
          end
        end
        assert(page.has_content?('Bar Changed'))

        visit storefront.search_path(q: 'product')
        assert(page.has_content?('Product 1'))
        assert(page.has_content?('Product 2'))

        visit storefront.root_path

        page.document.synchronize do
          within_frame find('.admin-toolbar') do
            find_field 'release_id'
            select 'the live site', from: 'release_id'
          end
        end
        assert(page.has_no_content?('New Taxon'))
      end
    end
  end
end
