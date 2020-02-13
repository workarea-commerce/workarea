require 'test_helper'

module Workarea
  module Storefront
    class PagesPerformanceTest < Workarea::PerformanceTest
      setup :setup_page

      def setup_page
        @page = create_page
        content = Content.for(@page)

        # Providing data for dynamic blocks to use
        @products = Array.new(6) { create_product }
        @categories = Array.new(3) { create_category(product_ids: @products.map(&:id)) }
        create_taxon(navigable: @categories.first)
        create_taxon(navigable: @page)

        Configuration::ContentBlocks.types.each do |type|
          3.times { content.blocks.build(type_id: type.id, data: type.defaults) }
        end

        content.save!
      end

      def test_heavy_content_pages
        get storefront.page_path(@page)
        assert(response.ok?)
      end
    end
  end
end
