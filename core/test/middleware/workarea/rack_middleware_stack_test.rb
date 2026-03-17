require 'test_helper'

module Workarea
  # Verifies that the middleware stack configured in
  # core/config/initializers/10_rack_middleware.rb is present and correctly
  # ordered for both Rails 6.1 and 7.x.
  class RackMiddlewareStackTest < TestCase
    def middleware_classes
      Rails.application.middleware.map(&:klass)
    end

    def test_mongo_query_cache_middleware_is_present
      assert_includes middleware_classes, Mongo::QueryCache::Middleware
    end

    def test_elasticsearch_query_cache_middleware_is_present
      assert_includes middleware_classes, Workarea::Elasticsearch::QueryCache::Middleware
    end

    def test_dragonfly_middleware_is_present
      assert_includes middleware_classes, Dragonfly::Middleware
    end

    def test_enforce_host_middleware_is_present
      assert_includes middleware_classes, Workarea::EnforceHostMiddleware
    end

    def test_application_middleware_is_present
      assert_includes middleware_classes, Workarea::ApplicationMiddleware
    end

    def test_application_middleware_wraps_dragonfly
      app_idx = middleware_classes.index(Workarea::ApplicationMiddleware)
      dragonfly_idx = middleware_classes.index(Dragonfly::Middleware)

      assert app_idx, "ApplicationMiddleware must be in the stack"
      assert dragonfly_idx, "Dragonfly::Middleware must be in the stack"
      assert app_idx < dragonfly_idx,
        "ApplicationMiddleware (pos #{app_idx}) must come before Dragonfly::Middleware (pos #{dragonfly_idx})"
    end

    def test_strip_http_caching_middleware_present_in_test_env
      assert_includes middleware_classes, Workarea::StripHttpCachingMiddleware
    end

    def test_rack_cache_not_inserted_on_rails_71_plus
      skip "Only relevant on Rails >= 7.1" unless
        Rails::VERSION::MAJOR > 7 ||
        (Rails::VERSION::MAJOR == 7 && Rails::VERSION::MINOR >= 1)

      refute_includes middleware_classes, Rack::Cache
    end

    def test_rack_cache_handling_does_not_raise
      # Ensure the middleware stack builds without raising regardless of
      # whether Rack::Cache is configured (regression guard for WA-RAILS7-009).
      assert_nothing_raised { Rails.application.middleware.to_a }
    end
  end
end
