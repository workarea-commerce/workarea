require 'test_helper'

module Workarea
  module Admin
    class ContentPresetsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_preset_creation
        content = create_content
        block = content.blocks.create!(
          type: 'html',
          data: { html: 'test_html' }
        )

        post admin.content_presets_path,
          params: {
            content_preset: { name: 'Foo Bar' },
            content_id: content.id,
            block_id: block.id
          },
          xhr: true

        preset = Content::Preset.first
        assert_response(:created)
        assert_equal('Foo Bar', preset.name)
        assert_equal(:html, preset.type_id)
        assert_equal({ 'html' => 'test_html' }, preset.data)
      end

      def test_preset_deletion
        preset = Content::Preset.create!(name: 'Test Preset')

        delete admin.content_preset_path(preset)
        assert_equal(0, Content::Preset.count)
      end
    end
  end
end
