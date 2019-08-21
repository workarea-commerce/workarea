require 'test_helper'

module Workarea
  module AssetEndpoints
    class FaviconsTest < TestCase
      def test_result
        Workarea.config.favicon_allowed_sizes = %w(32x32 16x16)

        endpoint = Favicons.new({ size: '32x32' }, nil, {})
        assert_includes(endpoint.result.url, Workarea.config.favicon_placeholder_image_name)

        default_asset = create_asset(tag_list: 'favicon')
        assert_equal(default_asset.favicon('32x32').url, endpoint.result.url)

        asset_32 = create_asset(tag_list: 'favicon-32x32')
        assert_equal(asset_32.favicon('32x32').url, endpoint.result.url)

        endpoint = Favicons.new({ size: '16x16' }, nil, {})
        assert_equal(default_asset.favicon('16x16').url, endpoint.result.url)

        endpoint = Favicons.new({ size: '64x64' }, nil, {})
        assert_nil(endpoint.result)
      end

      def test_ico
        endpoint = Favicons.new({}, nil, {})
        assert_includes(endpoint.ico.url, Workarea.config.favicon_placeholder_image_name)

        default_asset = create_asset(tag_list: 'favicon')
        assert_equal(default_asset.favicon_ico.url, endpoint.ico.url)

        asset_ico = create_asset(tag_list: 'favicon-ico')
        assert_equal(asset_ico.favicon_ico.url, endpoint.ico.url)
      end
    end
  end
end
