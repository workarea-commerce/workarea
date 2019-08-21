require 'test_helper'

module Workarea
  module Search
    class ProductFacetSortingTest < TestCase
      include TestCase::SearchIndexing

      setup :set_configs
      teardown :reset_configs

      def set_configs
        Workarea.configure do |config|
          @facet_sizes = config.search_facet_result_sizes
          @facet_sorting = config.search_facet_sorts
          @default_sorting = config.search_facet_default_sort
          @size_order = config.search_facet_size_sort

          config.search_facet_result_sizes = { color: 3, size: 3 }
          config.search_facet_default_sort = :count
          config.search_facet_size_sort = %(XS S M L XL)
        end
      end

      def reset_configs
        Workarea.configure do |config|
          config.search_facet_result_sizes = @facet_sizes
          config.search_facet_sorts = @facet_sorting
          config.search_facet_default_sort = @default_sorting
          config.search_facet_size_sort = @size_order
        end
      end

      def test_facet_sorting_for_product_search
        terms_facets = %w(Color Size)
        colors = %w(Red Blue Green Purple)
        sizes = %w(M S L XS)

        products = colors.each_with_index.flat_map do |color, i|
          Array.new(i + 1) do |j|
            create_product(filters: { 'Color' => colors[i], 'Size' => sizes[j] })
          end
        end

        BulkIndexProducts.perform_by_models(products)

        Workarea.config.search_facet_sorts = {
          color: :count,
          size: :alphabetical_asc
        }

        search = Search::ProductSearch.new(terms_facets: terms_facets)
        color_facets =
          search.response
                .dig('aggregations', 'color', 'color', 'buckets')
                .map { |color| color['key'] }

        size_facets =
          search.response
                .dig('aggregations', 'size', 'size', 'buckets')
                .map { |size| size['key'] }

        assert_equal(%w(Purple Green Blue), color_facets)
        assert_equal(%w(Purple Green Blue), search.facets.first.results.keys)
        assert_equal(%w(L M S), size_facets)
        assert_equal(%w(L M S), search.facets.second.results.keys)

        Workarea.config.search_facet_sorts = {
          color: ->(name, results) { Hash[results.sort] },
          size: 'Workarea::Search::FacetSorting::Size'
        }

        search = Search::ProductSearch.new(terms_facets: terms_facets)
        color_facets =
          search.response
                .dig('aggregations', 'color', 'color', 'buckets')
                .map { |color| color['key'] }

        size_facets =
          search.response
                .dig('aggregations', 'size', 'size', 'buckets')
                .map { |size| size['key'] }

        assert_equal(%w(Purple Green Blue Red), color_facets)
        assert_equal(%w(Blue Green Purple), search.facets.first.results.keys)
        assert_equal(%w(M S L XS), size_facets)
        assert_equal(%w(XS S M), search.facets.second.results.keys)
      end
    end
  end
end
