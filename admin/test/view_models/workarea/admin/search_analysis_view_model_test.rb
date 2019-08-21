require 'test_helper'

module Workarea
  module Admin
    class SearchAnalysisViewModelTest < TestCase
      include TestCase::SearchIndexing

      setup :create_products

      def create_products
        @product_one = create_product(name: 'Foo')
        @product_two = create_product(name: 'Foo Bar')
      end

      def test_scores
        customization = create_search_customization(
          id: 'foo',
          query: 'Foo',
          product_ids: [@product_two.id]
        )
        BulkIndexProducts.perform

        view_model = SearchAnalysisViewModel.wrap(customization)

        assert_equal(2, view_model.scores.size)
        assert(view_model.scores.all? { |s| s.score.present? })
        assert_equal(@product_two.id, view_model.scores.first.id)
        assert(view_model.scores.first.featured?)
        assert_equal(@product_one.id, view_model.scores.second.id)
        refute(view_model.scores.second.featured?)
      end

      def test_middleware
        customization = create_search_customization(
          id: @product_one.id,
          query: @product_one.id
        )

        BulkIndexProducts.perform
        view_model = SearchAnalysisViewModel.wrap(customization)

        Workarea.config.storefront_search_middleware = SwappableList.new(
          %w(
            Workarea::Search::StorefrontSearch::Redirect
            Workarea::Search::StorefrontSearch::ExactMatches
            Workarea::Search::StorefrontSearch::ProductMultipass
            Workarea::Search::StorefrontSearch::SpellingCorrection
            Workarea::Search::StorefrontSearch::Template
          )
        )

        assert_equal(5, view_model.middleware.size)
        assert_equal(:pass, view_model.middleware[Search::StorefrontSearch::Redirect])
        assert_equal(:last, view_model.middleware[Search::StorefrontSearch::ExactMatches])
        assert_equal(:ignore, view_model.middleware[Search::StorefrontSearch::ProductMultipass])
        assert_equal(:ignore, view_model.middleware[Search::StorefrontSearch::SpellingCorrection])
        assert_equal(:ignore, view_model.middleware[Search::StorefrontSearch::Template])
      end

      def test_tokens
        customization = create_search_customization(id: 'foo', query: 'Foo')
        Search::Settings.current.update_attributes!(synonyms: 'foo, bar')
        BulkIndexProducts.perform

        view_model = SearchAnalysisViewModel.wrap(customization)
        assert_equal(2, view_model.tokens.size)
        assert_equal('ALPHANUM', view_model.tokens['foo'])
        assert_equal('SYNONYM', view_model.tokens['bar'])
      end
    end
  end
end
