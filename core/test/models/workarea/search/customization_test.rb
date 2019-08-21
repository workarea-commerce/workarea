require 'test_helper'

module Workarea
  module Search
    class CustomizationTest < TestCase
      include FeaturedProductsTest

      def featured_product_model
        @featured_product_model ||= create_category
      end

      def test_disallow_star_query
        customization = Customization.new(id: 'bag', query: '*')

        refute(customization.valid?)
        refute_empty(customization.errors.messages[:query])
        assert_includes(customization.errors.messages[:query], "cannot be '*'")
      end

      def test_find_query_query_returns_existing
        customization = Customization.new(id: 'bag', query: 'bag')

        assert_equal(customization, Customization.find_by_query('bag'))
      end

      def test_find_query_query_returns_null_object
        refute_nil(Customization.find_by_query('bag'))
      end

      def test_positions_for_product
        create_search_customization(id: 'foo', product_ids: %w(a b c))
        create_search_customization(id: 'bar', product_ids: %w(b a c))
        create_search_customization(id: 'baz', product_ids: %w(c b a))

        assert_equal(
          { 'foo' => 0, 'bar' => 1, 'baz' => 2 },
          Customization.positions_for_product('a')
        )

        assert_equal(
          { 'foo' => 1, 'bar' => 0, 'baz' => 1 },
          Customization.positions_for_product('b')
        )

        assert_equal(
          { 'foo' => 2, 'bar' => 2, 'baz' => 0 },
          Customization.positions_for_product('c')
        )
      end

      def test_redirect
        cust = Customization.new(query: 'bag', redirect: 'cart')
        assert_equal('/cart', cust.redirect)

        cust = Customization.new(query: 'bag', redirect: '/cart')
        assert_equal('/cart', cust.redirect)

        cust = Customization.new(query: 'blog', redirect: 'blog.example.com')
        assert_equal('http://blog.example.com', cust.redirect)

        cust = Customization.new(query: 'blog', redirect: 'http://blog.example.com')
        assert_equal('http://blog.example.com', cust.redirect)

        cust = Customization.new(query: 'blog', redirect: nil)
        assert_nil(cust.redirect)
      end
    end
  end
end
