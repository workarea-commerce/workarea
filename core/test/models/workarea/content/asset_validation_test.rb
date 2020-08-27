require 'test_helper'

module Workarea
  class Content
    class AssetValidationTest < TestCase
      setup :set_asset

      def set_asset
        @asset = Asset.new(file: product_image_file_path)
        FastImage.expects(:type).returns(nil)
      end

      def test_sets_an_image_type
        @asset.file.expects(:mime_type).returns('image/jpeg').at_least_once
        @asset.valid?
        assert_equal('image', @asset.type)
        assert(@asset.image?)
      end

      def test_sets_a_pdf_type
        @asset.file.expects(:mime_type).returns('application/pdf').at_least_once
        @asset.valid?
        assert_equal('pdf', @asset.type)
        assert(@asset.pdf?)
      end

      def test_sets_flash_type
        @asset.file.expects(:mime_type).returns('application/x-shockwave-flash').at_least_once
        @asset.valid?
        assert_equal('flash', @asset.type)
        assert(@asset.flash?)
      end

      def test_sets_audio_type
        @asset.file.expects(:mime_type).returns('audio/mpeg').at_least_once
        @asset.valid?
        assert_equal('audio', @asset.type)
        assert(@asset.audio?)
      end

      def test_sets_video_type
        @asset.file.expects(:mime_type).returns('video/quicktime').at_least_once
        @asset.valid?
        assert_equal('video', @asset.type)
        assert(@asset.video?)
      end

      def test_sets_text_type
        @asset.file.expects(:mime_type).returns('text/plain').at_least_once
        @asset.valid?
        assert_equal('text', @asset.type)
        assert(@asset.text?)
      end

      def test_sets_unknown_if_not_known
        @asset.file.expects(:mime_type).returns('asldfkjsklfj').at_least_once
        @asset.valid?
        assert_equal('unknown', @asset.type)
      end

      def test_sets_a_name_if_none_is_present
        @asset.file_name = 'file.jpg'
        @asset.valid?
        assert(@asset.name.present?)
      end
    end
  end
end
