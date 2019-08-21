require 'test_helper'

module Workarea
  module Search
    class Admin
      class ContentAssetTest < TestCase
        def test_search_text
          asset = create_asset(
            name: 'Foo',
            file_name: 'bar.txt',
            tag_list: 'one, two, three'
          )

          result = ContentAsset.new(asset).search_text

          assert_includes(result, 'Foo')
          assert_includes(result, 'bar.txt')
          assert_includes(result, 'one, two, three')
        end

        def test_placeholders
          Workarea.config.image_placeholder_image_name = 'foo.jpg'
          Workarea.config.open_graph_placeholder_image_name = 'bar.jpg'
          Workarea.config.favicon_placeholder_image_name = 'baz.jpg'

          image_placeholder = create_asset(
            name: 'Image',
            file_name: Workarea.config.image_placeholder_image_name,
          )

          open_graph_placeholder = create_asset(
            name: 'Open Graph',
            file_name: Workarea.config.open_graph_placeholder_image_name,
          )

          favicon_placeholder = create_asset(
            name: 'Favicon',
            file_name: Workarea.config.favicon_placeholder_image_name
          )

          image_result = ContentAsset.new(image_placeholder)
          open_graph_result = ContentAsset.new(open_graph_placeholder)
          favicon_result = ContentAsset.new(favicon_placeholder)

          refute(image_result.should_be_indexed?)
          refute(open_graph_result.should_be_indexed?)
          refute(favicon_result.should_be_indexed?)
        end
      end
    end
  end
end
