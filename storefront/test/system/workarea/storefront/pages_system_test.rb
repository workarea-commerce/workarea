require 'test_helper'

module Workarea
  module Storefront
    class PagesSystemTest < Workarea::SystemTest
      setup :set_content_page

      def set_content_page
        @content_page = create_page(name: 'Integration Page')
      end

      def test_showing_the_home_page
        create_content(
          name: 'home_page',
          blocks: [
            {
              type_id: 'html',
              data: { html: 'Home Page Product' }
            }
          ]
        )

        visit storefront.root_path
        assert(page.has_content?('Home Page Product'))
      end

      def test_showing_the_page
        visit storefront.page_path(@content_page)
        assert(page.has_content?('Integration Page'))
      end

      def test_rendering_left_navigation
        top_level = create_taxon(name: 'Foo Taxon', url: 'http://example.com')
        create_taxon(parent: top_level, name: 'Foo Taxon', navigable: @content_page)
        @content_page.update_attributes!(show_navigation: true)

        visit storefront.page_path(@content_page)
        within '.page-content__aside' do
          assert(page.has_content?('Foo Taxon'))
        end

        @content_page.update_attributes!(show_navigation: false)

        visit storefront.page_path(@content_page)
        assert(page.has_no_selector?('.page-content__aside'))
      end

      def test_showing_custom_page_templates
        product = create_product(name: 'Integration Page', template: 'test')
        visit storefront.product_path(product)
        assert(page.has_content?('This is for testing custom template rendering'))
      end

      def test_rendering_robots_txt
        visit storefront.robots_txt_path
        assert(page.has_content?('User-Agent: *'))
        assert(page.has_content?('Disallow: /')) # since this is the test env
      end
    end
  end
end
