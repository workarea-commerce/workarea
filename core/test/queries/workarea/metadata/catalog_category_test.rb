require 'test_helper'

module Workarea
  class Metadata
    class CatalogCategoryTest < TestCase
      setup :set_category
      setup :set_taxons
      setup :set_metadata

      def set_category
        @category = create_category(name: 'Foo')
      end

      def set_taxons
        taxon = create_taxon(navigable: @category)
        4.times { |i| create_taxon(name: "Foo-#{i}", parent: taxon) }
      end

      def set_metadata
        @metadata = Metadata::CatalogCategory.new(Content.for(@category))
      end

      def test_title
        assert_equal(
          'Foo: Foo-0, Foo-1, Foo-2, and Foo-3',
          @metadata.title
        )
      end

      def test_description
        assert_equal(
          'Shop Foo for a great selection including Foo-0, Foo-1, Foo-2, and Foo-3',
          @metadata.description
        )
      end
    end
  end
end
