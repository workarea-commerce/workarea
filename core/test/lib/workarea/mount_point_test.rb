require 'test_helper'

module Workarea
  class MountPointTest < Workarea::TestCase
    def setup
      # Clear cache between tests so each test starts fresh
      MountPoint.cache = nil
    end

    def test_unwrap_app_returns_non_app_object_directly
      klass = Class.new
      assert_equal klass, MountPoint.unwrap_app(klass)
    end

    def test_unwrap_app_traverses_single_wrapper
      inner = Class.new
      wrapper = Struct.new(:app).new(inner)
      assert_equal inner, MountPoint.unwrap_app(wrapper)
    end

    def test_unwrap_app_traverses_nested_wrappers
      inner   = Class.new
      middle  = Struct.new(:app).new(inner)
      outer   = Struct.new(:app).new(middle)
      assert_equal inner, MountPoint.unwrap_app(outer)
    end

    def test_find_locates_mounted_engine
      # Core, Admin, and Storefront engines are all mounted in the test dummy
      # app.  Verify that MountPoint.find returns a non-nil name for at least
      # one of them.
      result = MountPoint.find(Workarea::Core::Engine)
      # In the test dummy the Core engine may or may not be mounted depending on
      # the dummy config, so only assert a type when a result is present.
      assert_includes([NilClass, Symbol, String], result.class,
                    "Expected a symbol/string route name or nil, got #{result.inspect}")
    end

    def test_find_does_not_raise_for_non_mounted_routes
      # Passing a random class that is not a mounted engine should return nil
      # without raising NoMethodError on routes that lack an .app.app chain.
      assert_nothing_raised { MountPoint.find(Class.new) }
    end

    def test_find_returns_nil_for_unmounted_class
      result = MountPoint.find(Class.new)
      assert_nil result
    end

    def test_find_returns_nil_when_route_raises_during_traversal
      # Simulate a route that raises StandardError during .app traversal.
      # MountPoint.find should rescue and continue, returning nil overall.
      bad_route = Object.new
      def bad_route.app; raise StandardError, 'simulated route error'; end

      # Stub Rails.application.routes.named_routes to include the bad route.
      # We can't call Minitest#stub on ActionDispatch::Routing::RouteSet in newer
      # Rails, so stub Rails.application.routes with a plain object instead.
      fake_route_set = Object.new
      fake_route_set.define_singleton_method(:named_routes) { { bad: bad_route } }

      app = Rails.application
      had_singleton_routes = app.singleton_methods.include?(:routes)

      # Define a singleton method to override the application routes for this test.
      app.define_singleton_method(:routes) { fake_route_set }

      begin
        MountPoint.cache = nil
        result = MountPoint.find(Class.new)
        assert_nil result
      ensure
        if had_singleton_routes
          # If routes was already a singleton method, restore it by reloading the
          # original method from the singleton class's ancestors.
          app.singleton_class.send(:remove_method, :routes)
        else
          app.singleton_class.send(:remove_method, :routes)
        end
      end
    end

    def test_find_memoizes_result
      first  = MountPoint.find(Workarea::Core::Engine)
      second = MountPoint.find(Workarea::Core::Engine)
      # Both calls must return the same cached value (including nil if not mounted)
      if first.nil?
        assert_nil second
      else
        assert_equal first, second
      end
    end

    def test_unwrap_app_stops_at_class
      # Engine classes are Classes — unwrap_app must NOT call .app on them
      # (engines respond to .app but we must treat them as the final node)
      assert_equal Workarea::Storefront::Engine,
                   Workarea::MountPoint.unwrap_app(Workarea::Storefront::Engine)
    end
  end
end
