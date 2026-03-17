# frozen_string_literal: true

require 'test_helper'

module Workarea
  class MongoQueryCacheSmokeTest < TestCase
    def test_query_cache_api_exists_and_is_callable
      assert defined?(::Mongo::QueryCache), 'Expected Mongo::QueryCache to be defined'

      assert_respond_to(::Mongo::QueryCache, :cache)
      assert_respond_to(::Mongo::QueryCache, :uncached)

      clear_method =
        if ::Mongo::QueryCache.respond_to?(:clear_cache)
          :clear_cache
        else
          :clear
        end

      assert_respond_to(::Mongo::QueryCache, clear_method)

      assert_equal(:ok, ::Mongo::QueryCache.cache { :ok })
      assert_equal(:ok, ::Mongo::QueryCache.uncached { :ok })
      ::Mongo::QueryCache.public_send(clear_method)
    end

    def test_query_cache_middleware_exists_and_is_callable
      assert defined?(::Mongo::QueryCache::Middleware),
        'Expected Mongo::QueryCache::Middleware to be defined'

      app = ->(_env) { [200, { 'Content-Type' => 'text/plain' }, ['ok']] }
      middleware = ::Mongo::QueryCache::Middleware.new(app)

      status, headers, body = middleware.call({})

      assert_equal 200, status
      assert_equal 'text/plain', headers['Content-Type']
      assert_equal ['ok'], body
    end
  end
end
