module Workarea
  module Storefront
    module ProductBrowsingViewModelTest
      extend ActiveSupport::Concern
      include PaginationViewModelTest

      def pagination_view_model_class
        product_browsing_view_model_class
      end

      def test_has_filters
        view_model = product_browsing_view_model_class.new(stub_everything)
        facet = mock
        view_model.expects(:facets).returns([facet]).twice

        facet.expects(:selected?).returns(true)
        assert(view_model.has_filters?)

        facet.expects(:selected?).returns(false)
        refute(view_model.has_filters?)
      end

      def test_facets
        view_model = product_browsing_view_model_class.new(stub_everything)
        facets = [mock, mock]
        search = Search::ProductSearch.new
        search.expects(:facets).returns(facets).at_least_once
        view_model.expects(:search_query).returns(search).twice

        facets.first.stubs(:useless?).returns(true)
        facets.second.stubs(:useless?).returns(false)

        assert_equal(1, view_model.facets.size)
        refute(view_model.facets.first.useless?)
      end
    end
  end
end
