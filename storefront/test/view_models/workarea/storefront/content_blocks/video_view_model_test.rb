require 'test_helper'

module Workarea
  module Storefront
    module ContentBlocks
      class VideoViewModelTest < TestCase
        def youtube_complete
          <<-html
            <iframe width="400" height='200' src="//www.youtube.com/embed/gZakKwQ-gFM" frameborder="0" allowfullscreen>
            </iframe>
          html
        end

        def vimeo_complete
          <<-html
            <iframe src="//player.vimeo.com/video/102605293" width='400' height="100" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen>
            </iframe>
            <p>
              <a href="http://vimeo.com/102605293">This Way Up</a>
              from
              <a href="http://vimeo.com/nexusproductions">Nexus</a>
              on <a href="https://vimeo.com">Vimeo</a>.
            </p>
          html
        end

        def youtube_missing_width
          <<-html
            <iframe with="560" height='315' src="//www.youtube.com/embed/gZakKwQ-gFM" frameborder="0" allowfullscreen>
            </iframe>
          html
        end

        def vimeo_missing_height
          <<-html
            <iframe src="//player.vimeo.com/video/102605293" width='500' height="" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen>
            </iframe>
            <p>
              <a href="http://vimeo.com/102605293">This Way Up</a>
              from
              <a href="http://vimeo.com/nexusproductions">Nexus</a>
              on <a href="https://vimeo.com">Vimeo</a>.
            </p>
          html
        end

        def test_returns_inline_styles_for_youtube_embed_code
          block = Content::Block.new(
            type_id: :video,
            data: { 'embed' => youtube_complete }
          )

          view_model = VideoViewModel.new(block)
          assert_equal('padding-bottom: 50.0%; height: 0;', view_model.frame_styles)
        end

        def test_returns_inline_styles_for_vimeo_embed_code
          block = Content::Block.new(
            type_id: :video,
            data: { 'embed' => vimeo_complete }
          )

          view_model = VideoViewModel.new(block)
          assert_equal('padding-bottom: 25.0%; height: 0;', view_model.frame_styles)
        end

        def test_returns_nil_if_width_is_missing
          block = Content::Block.new(
            type_id: :video,
            data: { 'embed' => youtube_missing_width }
          )

          view_model = VideoViewModel.new(block)
          assert_nil(view_model.frame_styles)
        end

        def test_returns_nil_if_height_is_missing
          block = Content::Block.new(
            type_id: :video,
            data: { 'embed' => vimeo_missing_height }
          )

          view_model = VideoViewModel.new(block)
          assert_nil(view_model.frame_styles)
        end
      end
    end
  end
end
