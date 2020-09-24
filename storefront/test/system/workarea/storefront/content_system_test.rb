require 'test_helper'

module Workarea
  module Storefront
    class ContentSystemTest < Workarea::SystemTest
      include BreakpointHelpers
      setup :set_content_page

      def set_content_page
        @content_page = create_page(name: 'Integration Page')
      end

      def test_content_blocks
        product = create_product(name: 'Test Product')
        category = create_category(
          name: 'Test Standard Category',
          product_ids: [product.id]
        )

        product1 = create_product(name: 'PL Product 1')
        product2 = create_product(name: 'PL Product 2')

        asset = create_asset(alt_text: 'Foobarbq')

        content = Content.for(@content_page)
        content.blocks.build(
          type: :html,
          data: { html: 'test html' }
        )
        content.blocks.build(
          type: :text,
          data: { text: 'text' }
        )
        content.blocks.build(
          type: :image,
          data: { image: asset.id }
        )
        content.blocks.build(
          type: :image,
          data: {
             image: asset.id,
             alt: 'Corgenator'
          }
        )
        content.blocks.build(
          type: :hero,
          data: {
            asset: asset.id,
            text: 'foo headline',
            text_style: 'dark',
            text_link_position: 'Top, Left'
          }
        )
        content.blocks.build(
          type: :video,
          data: { embed: '<iframe src="https://foo.com"></iframe>' }
        )
        content.blocks.build(
          type: :category_summary,
          data: { category: category.id.to_s }
        )
        content.blocks.build(
          type: :product_list,
          data: {
            title: 'List Test Title',
            products: [product1.id, product2.id]
          }
        )
        content.save!

        visit storefront.page_path(@content_page)
        assert(page.has_content?('test html'))
        assert(page.has_content?('text'))
        assert(page.has_content?('foo headline'))
        assert_match(/alt.*Foobarbq/, page.html)
        assert_match(/alt.*Corgenator/, page.html)
        assert_match(/iframe/, page.html)
        assert(page.has_content?('Test Standard Category'))
        page.all(:css, '.category-summary-content-block').each do |el|
          assert(el.has_content?('Test Product'))
        end
        assert(page.has_content?('List Test Title'))
        assert(page.has_content?('PL Product 1'))
        assert(page.has_content?('PL Product 2'))
      end

      def test_layout_content
        create_content(
          name: 'Layout',
          blocks: [
            {
              area: :footer_navigation,
              type: 'html',
              data: { html: 'foo bar' }
            }
          ]
        )

        visit storefront.root_path
        assert(page.has_content?('foo bar'))
      end

      def test_responsively_visible_content_blocks
        Content.for(@content_page).blocks.create!(
          type: :html,
          data: { html: 'foo bar', barf: 'no' },
          hidden_breakpoints: ['medium']
        )

        visit storefront.page_path(@content_page)

        resize_window_to('small')
        assert(page.has_content?('foo bar'))

        resize_window_to('medium')
        refute_text('foo bar')

        resize_window_to('wide')
        assert(page.has_content?('foo bar'))
      end
    end
  end
end
