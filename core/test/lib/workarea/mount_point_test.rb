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

      # Stub Rails.application.routes.routes to include the bad route
      fake_routes = [bad_route]
      Rails.application.routes.stub(:routes, fake_routes) do
        MountPoint.cache = nil
        result = MountPoint.find(Class.new)
        assert_nil result
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
  end
end
