require 'test_helper'

module Workarea
  class QueryCacheMiddlewareTest < TestCase
    class FooWorker
      class << self
        def sidekiq_options=(value)
          @sidekiq_options = value
        end

        def sidekiq_options
          @sidekiq_options || {}
        end
      end
    end

    def test_call
      QueryCacheMiddleware.new({}).call(FooWorker.new, {}, :foo) do
        refute(Mongoid::QueryCache.enabled?)
        refute(Elasticsearch::QueryCache.enabled?)
      end

      FooWorker.sidekiq_options = { 'query_cache' => true }

      QueryCacheMiddleware.new({}).call(FooWorker.new, {}, :foo) do
        assert(Mongoid::QueryCache.enabled?)
        assert(Elasticsearch::QueryCache.enabled?)
      end

      FooWorker.sidekiq_options = { 'mongoid_query_cache' => true }

      QueryCacheMiddleware.new({}).call(FooWorker.new, {}, :foo) do
        assert(Mongoid::QueryCache.enabled?)
        refute(Elasticsearch::QueryCache.enabled?)
      end

      FooWorker.sidekiq_options = { 'elasticsearch_query_cache' => true }

      QueryCacheMiddleware.new({}).call(FooWorker.new, {}, :foo) do
        refute(Mongoid::QueryCache.enabled?)
        assert(Elasticsearch::QueryCache.enabled?)
      end

      FooWorker.sidekiq_options = {
        'elasticsearch_query_cache' => true,
        'mongoid_query_cache' => true
      }

      QueryCacheMiddleware.new({}).call(FooWorker.new, {}, :foo) do
        assert(Mongoid::QueryCache.enabled?)
        assert(Elasticsearch::QueryCache.enabled?)
      end
    end
  end
end
