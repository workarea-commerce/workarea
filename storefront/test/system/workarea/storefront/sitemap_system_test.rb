require 'test_helper'

module Workarea
  module Storefront
    class SitemapSystemTest < Workarea::SystemTest
      include Storefront::SystemTest

      setup :set_per_page
      teardown :reset_per_page

      def set_per_page
        @per_page = Workarea.config.per_page
        Workarea.config.per_page = 7
      end

      def reset_per_page
        Workarea.config.per_page = @per_page
      end

      def test_displaying_sitemap
        foo = create_taxon(name: 'Landing', url: '/')
        placeholder = create_taxon(name: 'Placeholder')

        create_taxon(name: "Page Active", parent: foo, navigable: create_page)
        create_taxon(name: "Page Inactive", parent: foo, navigable: create_page(active: false))
        create_taxon(name: "Category Active", parent: placeholder, navigable: create_category)
        create_taxon(name: "Category Inactive", parent: placeholder, navigable: create_category(active: false))

        visit storefront.sitemap_path
        within '.view' do
          assert(
            page.has_ordered_text?(
              'Home > Landing > Page Active',
              'Home > Landing',
              'Home > Placeholder > Category Active'
            )
          )
          assert(page.has_no_content?('Page Inactive'))
          assert(page.has_no_content?('Category Inactive'))
        end
      end

      def test_sitemap_pagination
        7.times { |i| create_taxon(name: "Link #{i}", url: '/') }

        visit storefront.sitemap_path
        assert(page.has_content?('Link 0'))
        assert(page.has_content?('Link 5'))
        assert(page.has_no_content?('Link 6'))

        click_link t('workarea.storefront.sitemaps.pagination.next')
        assert(page.has_content?('Link 6'))
        assert(page.has_no_content?('Link 0'))
      end
    end
  end
end
