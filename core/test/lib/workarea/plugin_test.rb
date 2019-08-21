require 'test_helper'

module Workarea
  class PluginTest < TestCase
    setup :persist_appends
    teardown :restore_appends

    def test_skip_appends
      Plugin.append_partials('foo.bar', 'foo/bar', 'foo/baz', 'bar/qux')

      appends = Plugin.partials_appends['foo.bar']

      skip_partials = ['foo/bar']
      remaining_appends = Plugin.skip_appends(appends, skip_partials)

      refute_includes(remaining_appends, 'foo/bar')

      skip_partials = [/bar/]
      remaining_appends = Plugin.skip_appends(appends, skip_partials)

      refute_includes(remaining_appends, 'foo/bar')
      refute_includes(remaining_appends, 'bar/qux')

      skip_partials = [Proc.new { |p| p.include?('baz') }]
      remaining_appends = Plugin.skip_appends(appends, skip_partials)

      refute_includes(remaining_appends, 'foo/baz')

      skip_partials = ['bar/qux', /baz/, Proc.new { |p| p.include?('/bar') }]
      remaining_appends = Plugin.skip_appends(appends, skip_partials)

      refute_includes(remaining_appends, 'foo/bar')
      refute_includes(remaining_appends, 'foo/baz')
      refute_includes(remaining_appends, 'bar/qux')

      appends = Plugin.partials_appends['empty']
      skip_partials = ['foo/bar']

      assert_equal({}, Plugin.skip_appends(appends, skip_partials))
    end

    def test_add_append
      foos = {}
      Plugin.add_append(foos, 'foo.bar', 'baz/bat')
      assert_includes(foos['foo.bar'], 'baz/bat')
    end

    def test_remove_append
      foos = { 'foo.bar' => ['baz/bat'] }

      Plugin.remove_append(foos, 'foo.bar', 'baz/bat')
      Plugin.remove_append(foos, 'foo.bar', 'not/there')

      refute_includes(foos['foo.bar'], 'baz/bat')
    end

    def test_stylesheet_appends
      Plugin.append_stylesheets('foo.bar', 'baz/bat')
      assert_includes(Plugin.stylesheets_appends['foo.bar'], 'baz/bat')

      Plugin.remove_stylesheets('foo.bar', 'baz/bat')
      refute_includes(Plugin.stylesheets_appends['foo.bar'], 'baz/bat')
    end

    def test_javascript_appends
      Plugin.append_javascripts('foo.bar', 'baz/bat')
      assert_includes(Plugin.javascripts_appends['foo.bar'], 'baz/bat')

      Plugin.remove_javascripts('foo.bar', 'baz/bat')
      refute_includes(Plugin.javascripts_appends['foo.bar'], 'baz/bat')
    end

    def test_partial_appends
      Plugin.append_partials('foo.bar', 'baz/bat')
      assert_includes(Plugin.partials_appends['foo.bar'], 'baz/bat')

      Plugin.remove_partials('foo.bar', 'baz/bat')
      refute_includes(Plugin.partials_appends['foo.bar'], 'baz/bat')
    end

    def test_version_is_defaulted_to_0_0_0
      assert_equal("0.0.0", Workarea::Storefront.version)
      assert_equal("0.0.0", Workarea::Admin.version)
    end

    private

    def persist_appends
      @original_stylesheets_appends = Plugin.stylesheets_appends
      @original_javascripts_appends = Plugin.javascripts_appends
      @original_partials_appends = Plugin.partials_appends
    end

    def restore_appends
      Plugin.stylesheets_appends = @original_stylesheets_appends
      Plugin.javascripts_appends = @original_javascripts_appends
      Plugin.partials_appends = @original_partials_appends
    end
  end
end
