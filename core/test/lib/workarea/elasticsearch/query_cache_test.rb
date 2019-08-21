require 'test_helper'

module Workarea
  module Elasticsearch
    class QueryCacheTest < TestCase
      include SearchIndexing

      setup :enable_workers
      setup :category
      setup :product
      setup :reset_web_mock
      setup :disable_query_cache
      teardown :restore_query_cache_enabled

      def enable_workers
        Sidekiq::Callbacks.enable(IndexProduct)
      end

      def reset_web_mock
        WebMock.reset!
      end

      def category
        @category ||= create_category(
          product_rules: [name: 'search', operator: 'equals', value: '*']
        )
      end

      def product
        @product ||= create_product
      end

      def disable_query_cache
        @current_query_cache_enabled = Elasticsearch::QueryCache.enabled?
        Elasticsearch::QueryCache.enabled = false
      end

      def restore_query_cache_enabled
        Elasticsearch::QueryCache.enabled = @current_query_cache_enabled
      end

      def test_when_query_cache_is_disabled
        Workarea::Search::Storefront::Product.find_categories(product)

        assert_requested :get, "#{Workarea::Search::Storefront.current_index.url}/_search"
      end

      def test_when_query_cache_is_enabled
        Workarea::Elasticsearch::QueryCache.enabled = true

        Workarea::Search::Storefront::Product.find_categories(product)

        WebMock.reset!

        Workarea::Search::Storefront::Product.find_categories(product)

        assert_not_requested :get, "#{Workarea::Search::Storefront.current_index.url}/_search"
      end

      def test_reset_when_updating_a_document
        Workarea::Elasticsearch::QueryCache.enabled = true

        Workarea::Search::Storefront::Product.find_categories(product)

        product.update_attributes(name: 'New Name')

        WebMock.reset!

        Workarea::Search::Storefront::Product.find_categories(product)

        assert_requested :get, "#{Workarea::Search::Storefront.current_index.url}/_search"
      end

      def test_reset_when_deleting_a_document
        Workarea::Elasticsearch::QueryCache.enabled = true

        Workarea::Search::Storefront::Product.find_categories(product)

        product.update_attributes(name: 'New Name')

        product_2 = create_product

        Workarea::Search::Storefront::Product.new(product_2).destroy

        WebMock.reset!

        Workarea::Search::Storefront::Product.find_categories(product)

        assert_requested :get, "#{Workarea::Search::Storefront.current_index.url}/_search"
      end
    end
  end
end
