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
      include HttpCaching
      before_action :cache_page, only: :foo

      def set_session
        session[:foo] = params[:foo]
      end

      def foo
        render plain: session[:foo].presence || 'nil'
      end

      def varies
        render plain: request.env['workarea.cache_varies']
      end

      def current_user
        nil
      end
    end

    setup do
      Rails.application.routes.prepend do
        post 'cache_varies_test_set_session', to: 'workarea/cache_varies_integration_test/caching#set_session'
        get 'cache_varies_test_foo', to: 'workarea/cache_varies_integration_test/caching#foo'

        scope '(:locale)', constraints: Workarea::I18n.routes_constraint do
          get 'cache_varies_test_varies', to: 'workarea/cache_varies_integration_test/caching#varies'
          patch 'cache_varies_test_varies', to: 'workarea/cache_varies_integration_test/caching#varies'
        end
      end

      Rails.application.reload_routes!
    end

    def app
      @app ||= Rack::Builder.new do
        use AddEnvMiddleware
        use ApplicationMiddleware
        use Rack::Cache, metastore: 'heap:/', entitystore: 'heap:/'
        run Rails.application
      end
    end

    def test_varies_on_session
      Workarea.config.strip_http_caching_in_tests = false
      Workarea.config.cache_varies = [lambda { session[:foo] }]

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

    def test_varies_includes_locale
      set_locales(available: [:en, :es], default: :en, current: :en)

      get '/cache_varies_test_varies'
      assert_includes(response.body, 'en')

      get '/cache_varies_test_varies', params: { locale: 'es' }
      assert_includes(response.body, 'es')

      get '/es/cache_varies_test_varies'
      assert_includes(response.body, 'es')

      patch '/cache_varies_test_varies'
      assert_includes(response.body, 'en')

      patch '/cache_varies_test_varies', params: { locale: 'es' }
      assert_includes(response.body, 'es')

      patch '/es/cache_varies_test_varies'
      assert_includes(response.body, 'es')
    end
  end
end
