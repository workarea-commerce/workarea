require 'test_helper'

module Workarea
  class CacheVariesIntegrationTest < Workarea::IntegrationTest
    class AddEnvMiddleware
      def initialize(app)
        @app = app
      end

      def call(env)
        env.merge!(Rails.application.env_config)
        @app.call(env)
      end
    end

    class CachingController < Workarea::ApplicationController
      include Storefront::HttpCaching
      before_action :cache_page, only: :foo

      def set_session
        session[:foo] = params[:foo]
      end

      def foo
        render plain: session[:foo].presence || 'nil'
      end

      def current_user
        nil
      end
    end

    setup do
      Rails.application.routes.prepend do
        post 'cache_varies_test_set_session', to: 'workarea/cache_varies_integration_test/caching#set_session'
        get 'cache_varies_test_foo', to: 'workarea/cache_varies_integration_test/caching#foo'
      end

      Rails.application.reload_routes!
    end

    def app
      @app ||= Rack::Builder.new do
        use AddEnvMiddleware
        use RackCacheConfigMiddleware
        use Rack::Cache, metastore: 'heap:/', entitystore: 'heap:/'
        run Rails.application
      end
    end

    def test_varies_on_session
      Workarea.with_config do |config|
        config.strip_http_caching_in_tests = false
        config.cache_varies = [lambda { session[:foo] }]

        get '/cache_varies_test_foo'
        assert_equal('nil', response.body)
        assert_equal('miss, store', response.headers['X-Rack-Cache'])

        post '/cache_varies_test_set_session', params: { foo: 'bar' }
        get '/cache_varies_test_foo'
        assert_equal('bar', response.body)
        assert_equal('miss, store', response.headers['X-Rack-Cache'])

        get '/cache_varies_test_foo'
        assert_equal('bar', response.body)
        assert_equal('fresh', response.headers['X-Rack-Cache'])

        post '/cache_varies_test_set_session', params: { foo: 'baz' }
        get '/cache_varies_test_foo'
        assert_equal('baz', response.body)
        assert_equal('miss, store', response.headers['X-Rack-Cache'])

        get '/cache_varies_test_foo'
        assert_equal('baz', response.body)
        assert_equal('fresh', response.headers['X-Rack-Cache'])
      end
    end
  end
end
