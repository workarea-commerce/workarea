require 'test_helper'

module Workarea
  module Storefront
    class FaviconsIntegrationTest < Workarea::IntegrationTest
      def test_rendering_favicon_tags
        get storefront.root_path

        assert_select('link[rel="icon"]')
        assert_select('link[rel="manifest"]')
        assert_select('meta[name="msapplication-config"]')
        assert_select('meta[name="theme-color"]')
      end
    end
  end
end
