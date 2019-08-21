require 'test_helper'

module Workarea
  module Search
    class FacetMatchesTest < TestCase
      include TestCase::SearchIndexing

      setup :set_search

      def set_search
        create_product(filters: { color: %w(Red Green Blue), size: 'M' })
        create_product(filters: { color: %w(Green Blue), size: 'S' })
        create_product(filters: { color: %w(Blue), size: 'Blue' })

        BulkIndexProducts.perform
        @search = Search::ProductSearch.new(q: '*', terms_facets: %w(color size))
      end

      def test_matches_has_params_for_matching_queries
        facet_matches = FacetMatches.new(
          @search.params.merge(q: 'red dress'),
          @search.facets
        )
        assert_equal({ 'color' => ['Red'] }, facet_matches.matches)

        facet_matches = FacetMatches.new(
          @search.params.merge(q: 'dresses that are red'),
          @search.facets
        )
        assert_equal({ 'color' => ['Red'] }, facet_matches.matches)

        facet_matches = FacetMatches.new(
          @search.params.merge(q: 'some red dresses'),
          @search.facets
        )
        assert_equal({ 'color' => ['Red'] }, facet_matches.matches)
      end

      def test_params_merges_with_matches
        params = @search.params.merge(q: 'red dresses')

        facet_matches = FacetMatches.new(params, @search.facets)
        assert_equal('red dresses', facet_matches.params[:q])
        assert_equal(['Red'], facet_matches.params[:color])
      end

      def test_matches_only_returns_params_when_there_is_one_match
        params = @search.params.merge(q: 'blue dresses')

        facet_matches = FacetMatches.new(params, @search.facets)
        assert_equal(params, facet_matches.params)
      end
    end
  end
end
