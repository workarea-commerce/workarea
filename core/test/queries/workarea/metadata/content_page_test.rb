require 'test_helper'

module Workarea
  class Metadata
    class ContentPageTest < TestCase
      setup :set_page_and_metadata

      def set_page_and_metadata
        @page = create_page(name: 'Foo')
        @content = Content.for(@page)
        @metadata = ContentPage.new(@content)
      end

      def test_defaults_to_page_name
        assert_equal('Foo', @metadata.title)
      end

      def test_includes_parent_taxon_if_available
        category = create_category(name: 'Bar')
        taxon = create_taxon(name: 'Bar', navigable: category)
        create_taxon(name: 'Foo', parent: taxon, navigable: @page)

        assert_equal('Foo - Bar', @metadata.title)
      end

      def test_defaults_to_text_extracted_from_content_blocks
        @content.blocks.create!(
          type: 'html',
          data: { html: '<p>Lorem ipsum dolor</p>' }
        )

        assert_equal('Lorem ipsum dolor', @metadata.description)
      end
    end
  end
end
