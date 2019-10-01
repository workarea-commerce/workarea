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

        within_frame find('.admin-toolbar') do
          wait_for_iframe
          select 'Browse Release', from: 'release_id'
        end
        assert(page.has_content?('New Taxon'))

        visit storefront.page_path(page1)

        within_frame find('.admin-toolbar') do
          wait_for_iframe
          select 'the live site', from: 'release_id'
        end
        assert(page.has_no_content?('Foo Changed'))

        within_frame find('.admin-toolbar') do
          wait_for_iframe
          select 'Browse Release', from: 'release_id'
        end
        assert(page.has_content?('Foo Changed'))

        visit storefront.page_path(page2)

        within_frame find('.admin-toolbar') do
          wait_for_iframe
          select 'the live site', from: 'release_id'
        end
        assert(page.has_no_content?('Bar Changed'))

        within_frame find('.admin-toolbar') do
          wait_for_iframe
          select 'Browse Release', from: 'release_id'
        end
        assert(page.has_content?('Bar Changed'))

        visit storefront.search_path(q: 'product')
        assert(page.has_content?('Product 1'))
        assert(page.has_content?('Product 2'))

        visit storefront.root_path

        within_frame find('.admin-toolbar') do
          wait_for_iframe
          select 'the live site', from: 'release_id'
        end
        assert(page.has_no_content?('New Taxon'))
      end

      private

      # There is some kind of timing problem around waiting for this iframe that
      # after a few hours we still can't find. This is a hack to keep this
      # passing.
      #
      # May God have mercy on our souls.
      #
      # TODO v3.6
      # Remove this after we stop using an iframe for the admin toolbar
      #
      def wait_for_iframe
        sleep(0.5)
      end
    end
  end
end
