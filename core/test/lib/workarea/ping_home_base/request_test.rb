require 'test_helper'

module Workarea
  class PingHomeBase
    class RequestTest < Workarea::TestCase
      def test_plugins_exclude_core_gems
        plugin_names = request_hash[:plugins].map { |plugin| plugin[:name] }
        refute_includes(plugin_names, "Admin")
        refute_includes(plugin_names, "Storefront")
      end

      def test_includes_ruby_version
        assert_equal(RUBY_VERSION, request_hash[:ruby_version])
      end

      private

      def request_hash
        Request.new.to_h
      end
    end
  end
end
