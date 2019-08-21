require 'test_helper'

module Workarea
  module Admin
    class SearchViewModelTest < TestCase
      include TestCase::SearchIndexing

      def test_only_includes_persisted_results
        search = Search::AdminSearch.new
        results = PagedArray.from(
          [create_product, create_product, Catalog::Product.new],
          1,
          10,
          3
        )

        search.expects(:results).returns(results).at_least_once

        view_model = SearchViewModel.new(search)
        assert_equal(2, view_model.results.length)
        assert_equal(2, view_model.total)
      end

      def test_sort
        search = SearchViewModel.new
        assert_equal(Sort.modified, search.sort)

        search = SearchViewModel.new(mock, q: 'test')
        assert_equal(Sort.relevance, search.sort)

        search = SearchViewModel.new(mock, sort: 'name_asc')
        assert_equal(Sort.name_asc, search.sort)
      end
    end
  end
end
