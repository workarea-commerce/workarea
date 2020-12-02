require 'test_helper'

module Workarea
  class MetadataTest < TestCase
    class FooMetadata < Metadata
      def title
        'title'
      end

      def description
        'description'
      end
    end

    def test_disabling_globally
      Workarea.config.automate_seo_data = false

      metadata = FooMetadata.new(create_content(browser_title: nil, meta_description: nil))
      metadata.update

      assert_nil(metadata.content.reload.browser_title)
      assert_nil(metadata.content.meta_description)

      Workarea.config.automate_seo_data = true
      metadata.update

      assert_equal('title', metadata.content.browser_title)
      assert_equal('description', metadata.content.meta_description)
    end
  end
end
