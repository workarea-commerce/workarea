require 'test_helper'

module Workarea
  module Storefront
    class SearchIntegrationTest < Workarea::IntegrationTest
      def test_redirects_when_a_redirect_is_setup
        create_search_customization(
          id: 'cart',
          redirect: storefront.cart_path
        )

        get storefront.search_path(q: 'cart')
        assert_redirected_to(storefront.cart_path)
      end

      def test_handles_invalid_queries
        get storefront.search_path(q: '{()!}'),
          headers: { 'HTTP_REFERER' => '/foo' }
        assert(flash[:error].present?)
        assert_redirected_to('/foo')

        get storefront.search_path(q: ''),
          headers: { 'HTTP_REFERER' => '/foo' }
        assert(flash[:error].present?)
        assert_redirected_to('/foo')
      end

      def test_exact_match_redirecting
        create_product(
          id: 'F2234234-1234',
          name: 'Other Sweet Product',
          variants: [
            { sku: 'SKU5', regular: 5.to_m },
            { sku: 'SKU6', regular: 7.to_m }
          ]
        )

        product = create_product(
          id: 'F2-1234',
          name: 'My Sweet Product',
          variants: [
            { sku: 'SKU2', regular: 5.to_m },
            { sku: 'SKU3', regular: 7.to_m }
          ]
        )

        get storefront.search_path(q: ' f2-1234')
        assert_redirected_to(storefront.product_path(product))

        get storefront.search_path(q: ' my sweet  product ')
        assert_redirected_to(storefront.product_path(product))

        get storefront.search_path(q: 'SKu3 ')
        assert_redirected_to(storefront.product_path(product))

        get storefront.search_path(q: 'sweet product')
        refute(response.redirect?)

        Workarea.with_config do |config|
          config.search_name_phrase_match_boost = 9999999
          get storefront.search_path(q: 'sweet product')
          refute(response.redirect?)
        end

        Search::Settings.current.update_attributes!(boosts: { 'name': 9999999 })
        get storefront.search_path(q: 'sweet product')
        refute(response.redirect?)
      end

      def test_not_found_when_no_results
        create_product(name: 'Foo A')
        create_product(name: 'Foo B')

        get storefront.search_path(q: 'foo')
        assert(response.ok?)

        get storefront.search_path(q: 'asdfkj adfslj adsf')
        assert(response.not_found?)
      end

      def test_searching_for_everything
        create_product(name: 'Foo A')
        create_product(name: 'Foo B')

        get storefront.search_path(q: '*')
        assert(response.ok?)
        assert_includes(response.body, 'Foo A')
        assert_includes(response.body, 'Foo B')
      end

      def test_not_accepting_per_page_param
        one = create_product(name: 'Foo A')
        two = create_product(name: 'Foo B')

        get storefront.search_path(q: 'foo', page: 1, per_page: 1)
        assert(response.ok?)
        assert_includes(response.body, storefront.product_path(one))
        assert_includes(response.body, storefront.product_path(two))
      end
    end
  end
end
