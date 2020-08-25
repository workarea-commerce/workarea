require 'test_helper'

module Workarea
  module Storefront
    class ContentHelperTest < ViewTest
      include Workarea::ApplicationHelper

      def test_render_content_blocks
        content = create_content
        content.blocks.create!(type: :html)
        blocks = ContentBlockViewModel.wrap(content.blocks)

        self.expects(:current_user).returns(nil)
        self.expects(:request).returns(OpenStruct.new(env: {}))
        Rails.cache.expects(:fetch).once
        render_content_blocks(blocks)

        self.expects(:current_user).returns(create_user(admin: true))
        Rails.cache.expects(:fetch).never
        render_content_blocks(blocks)
      end

      def test_intrinsic_ratio_frame_styles
        asset = create_asset(file: product_image_file_path)
        result = intrinsic_ratio_frame_styles(asset)
        assert_equal('padding: 0 0 100.0%; height: 0;', result)

        asset = create_asset(
          file: product_image_file_path,
          file_inverse_aspect_ratio: nil
        )

        result = intrinsic_ratio_frame_styles(asset)
        assert(result.blank?)
      end

      def test_content_block_classes
        content = create_content
        content.blocks.create!(
          type: :image_group,
          data: {
            hidden_breakpoints: []
          }
        )
        blocks = ContentBlockViewModel.wrap(content.blocks)

        assert_equal(['content-block', "content-block--image-group"], content_block_classes_for(blocks.first))
      end
    end
  end
end
