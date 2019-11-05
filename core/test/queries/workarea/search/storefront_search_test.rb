require 'test_helper'

module Workarea
  module Search
    class StorefrontSearchTest < TestCase
      include SearchIndexing

      def test_is_redirect_if_one_exists
        create_search_customization(id: 'cart', redirect: '/cart')
        response = StorefrontSearch.new(q: 'cart').response
        assert(response.redirect?)
        assert_equal('/cart', response.redirect)
      end

      def test_is_redirect_as_first_priority
        create_page(name: 'Page')
        create_search_customization(id: 'page', redirect: '/')

        response = StorefrontSearch.new(q: 'page').response
        assert(response.redirect?)
        assert_equal('/', response.redirect)
      end

      def test_is_no_results_if_none
        response = StorefrontSearch.new(q: 'asdfkljaslkdfj').response
        assert_equal('no_results', response.template)
      end

      def test_is_redirect_to_first_product_if_one_result_and_no_filters
        IndexProduct.perform(create_product(name: 'Foo'))

        response = StorefrontSearch.new(q: 'foo').response
        assert(response.redirect?)
        assert(response.redirect.present?)
      end

      def test_is_show_if_multiple_results
        IndexProduct.perform(create_product(name: 'Foo'))
        IndexProduct.perform(create_product(name: 'Foo'))

        response = StorefrontSearch.new(q: 'foo').response
        assert_equal('show', response.template)
      end

      def test_product_multipass
        IndexProduct.perform(
          create_product(name: 'Foo Product')
        )
        IndexProduct.perform(
          create_product(name: 'Test Product', description: 'foo')
        )

        # Does not use multipass, skips descriptions
        assert_equal(2, StorefrontSearch.new(q: 'foo').response.total)
      end

      def test_only_finds_active_customizations
        customization = Search::Customization.find_by_query('foo')
        search = StorefrontSearch.new(q: 'foo')
        assert_equal(customization, search.customization)

        customization.update!(active: false)
        search = StorefrontSearch.new(q: 'foo')
        refute_equal(customization, search.customization)
        refute(search.customization.persisted?)
      end

      def test_keeps_track_of_middleware
        Workarea.config.storefront_search_middleware = SwappableList.new(
          %w(
            Workarea::Search::StorefrontSearch::Redirect
            Workarea::Search::StorefrontSearch::ExactMatches
            Workarea::Search::StorefrontSearch::ProductMultipass
            Workarea::Search::StorefrontSearch::SpellingCorrection
            Workarea::Search::StorefrontSearch::Template
          )
        )

        assert_equal(5, StorefrontSearch.new(q: '*').used_middleware.size)

        product = create_product(name: 'Foo Product')
        IndexProduct.perform(product)

        exact_match = StorefrontSearch.new(q: product.id)
        assert_equal(2, exact_match.used_middleware.size)
        assert_kind_of(StorefrontSearch::ExactMatches, exact_match.used_middleware.last)
      end

      def test_tracing
        Workarea.config.storefront_search_middleware = SwappableList.new(
          %w(
            Workarea::Search::StorefrontSearch::Redirect
            Workarea::Search::StorefrontSearch::ExactMatches
            Workarea::Search::StorefrontSearch::ProductMultipass
            Workarea::Search::StorefrontSearch::SpellingCorrection
            Workarea::Search::StorefrontSearch::Template
          )
        )

        trace = StorefrontSearch.new(q: '*').response.trace

        assert_equal(3, trace.size)
        assert_nil(trace.first.reset_by)
        assert_kind_of(StorefrontSearch::ProductMultipass, trace.second.reset_by)
        assert_kind_of(StorefrontSearch::ProductMultipass, trace.third.reset_by)
      end

      def test_exact_match_customization
        IndexProduct.perform(create_product(id: '1', name: 'Foo'))
        IndexProduct.perform(create_product(id: '2', name: 'Bar'))
        IndexProduct.perform(create_product(id: '3', name: 'Baz'))
        create_search_customization(
          id: 'foo', query: 'foo', product_ids: %w(2 3)
        )

        search = StorefrontSearch.new(q: 'foo')

        refute_nil(search.response.customization)
        assert_nil(search.response.redirect)
        refute_kind_of(StorefrontSearch::ExactMatches, search.used_middleware.last)
      end
    end
  end
end
