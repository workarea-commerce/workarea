require 'test_helper'

module Workarea
  module Search
    class RelatedProductsTest < IntegrationTest
      setup :set_taxonomy

      def set_taxonomy
        @category_one = create_category
        primary = create_taxon(name: 'One')
        create_taxon(parent: primary, navigable: @category_one)

        @category_two = create_category
        primary = create_taxon(name: 'Two')
        create_taxon(parent: primary, navigable: @category_two)
      end

      def test_only_available_products
        one = create_product(name: 'Foo Bar Baz 1')
        two = create_product(active: false, name: 'Foo Bar Baz 2')

        @category_one.update_attributes!(product_ids: [one.id, two.id])

        search = RelatedProducts.new(product_ids: one.id)
        assert_equal(0, search.total)
      end

      def test_filters_to_match_products_in_the_same_primary_navigation
        one = create_product(name: 'Foo Bar Baz 1')
        two = create_product(name: 'Foo Bar Baz 2')
        create_product(name: 'Foo Bar Baz 3')

        # Ignore if the product has no primary navigation
        search = RelatedProducts.new(product_ids: one.id)
        assert_equal(2, search.total)

        @category_one.update_attributes!(product_ids: [one.id, two.id])

        search = RelatedProducts.new(product_ids: one.id)
        assert_equal(1, search.total)
        assert_equal(two, search.results.first[:model])
      end

      def test_excludes_exclude_product_ids_if_passed_in
        one = create_product(name: 'Foo Bar Baz 1')
        two = create_product(name: 'Foo Bar Baz 2')
        three = create_product(name: 'Foo Bar Baz 3')

        @category_one.update_attributes!(product_ids: [one.id, two.id, three.id])

        search = RelatedProducts.new(product_ids: one.id)
        results = search.results.map { |r| r[:model] }
        assert_equal(2, search.total)
        assert_includes(results, two)
        assert_includes(results, three)

        search = RelatedProducts.new(
          product_ids: one.id,
          exclude_product_ids: three.id
        )

        assert_equal(1, search.total)
        assert_equal(two, search.results.first[:model])
      end

      def test_excludes_products_displayable_when_out_of_stock
        in_stock_standard = create_product(name: 'Foo Bar Baz 1', variants: [{ sku: '1' }])
        in_stock = create_product(name: 'Foo Bar Baz 2', variants: [{ sku: '2' }])
        out_of_stock = create_product(name: 'Foo Bar Baz 3', variants: [{ sku: '3' }])

        create_inventory(id: '1', policy: 'standard', available: 5)
        create_inventory(id: '2', policy: 'displayable_when_out_of_stock', available: 5)
        create_inventory(id: '3', policy: 'displayable_when_out_of_stock', available: 0)

        search = RelatedProducts.new(product_ids: in_stock_standard.id)
        assert_equal(1, search.total)
        assert_equal(in_stock, search.results.first[:model])
      end
    end
  end
end
