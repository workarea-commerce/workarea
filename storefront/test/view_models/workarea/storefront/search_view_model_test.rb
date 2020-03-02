require 'test_helper'

module Workarea
  module Storefront
    class SearchViewModelTest < TestCase
      include SearchIndexing
      include ProductBrowsingViewModelTest
      include PaginationViewModelTest

      def view_model_class
        SearchViewModel
      end
      alias_method :pagination_view_model_class, :view_model_class
      alias_method :search_content_view_model_class, :view_model_class
      alias_method :product_browsing_view_model_class, :view_model_class

      def create_search_response(options = {})
        attributes = { params: {} }.merge(options)

        result = Workarea::Search::StorefrontSearch::Response.new(attributes)
        result.query = attributes[:query] if attributes[:query]
        result
      end

      def test_product
        products = [create_product(name: 'Foo 1'), create_product(name: 'Foo 2')]
        BulkIndexProducts.perform_by_models(products)

        search_query = Search::ProductSearch.new(q: 'foo')
        response = create_search_response(query: search_query)
        view_model = SearchViewModel.new(response)

        assert(
          view_model
            .products
            .first
            .instance_of?(ProductViewModel)
        )
      end

      def test_sorts
        view_model = SearchViewModel.new(create_search_response)
        assert_equal(['Relevance', :relevance], view_model.sorts.first)
      end

      def test_query_suggestions
        response = create_search_response

        Recommendation::Searches.expects(:find).returns(%w(one))
        response.query.expects(:query_suggestions).returns(%w(two))

        view_model = SearchViewModel.new(response)
        assert_equal(%w(one two), view_model.query_suggestions)

        Recommendation::Searches.expects(:find).returns(%w(one))
        response.query.expects(:query_suggestions).returns(%w(one))

        view_model = SearchViewModel.new(response)
        assert_equal(%w(one), view_model.query_suggestions)
      end
    end
  end
end
