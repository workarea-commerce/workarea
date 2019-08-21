require 'test_helper'

module Workarea
  class Content
    class AssetTest < TestCase
      def test_image_placeholder
        assert(Asset.image_placeholder.present?)
      end

      def test_open_graph_placeholder
        assert(Asset.open_graph_placeholder.present?)
      end

      def test_favicon_placeholder
        assert(Asset.favicon_placeholder.present?)
      end

      def test_requires_a_file
        new_asset = Asset.new
        refute(new_asset.valid?)
      end

      def test_favicons
        create_asset(tag_list: 'favicon')
        create_asset(tag_list: 'favicon, favicon-32x32')

        assert_equal(2, Asset.favicons.count)
        assert_equal(1, Asset.favicons('32x32').count)
      end
    end
  end
end
