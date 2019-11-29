require 'test_helper'

module Workarea
  module Admin
    class ContentViewModelTest < TestCase

      def test_areas
        model = Content.new(name: 'Checkout')
        view_model = ContentViewModel.new(model)

        assert_equal(
          Workarea.config.content_areas['checkout'],
          view_model.areas
        )

        model = Content.new(contentable: create_category)
        view_model = ContentViewModel.new(model)

        assert_equal(
          Workarea.config.content_areas['category'],
          view_model.areas
        )

        model = Content.new(name: 'Special Content')
        view_model = ContentViewModel.new(model)

        assert_equal(
          Workarea.config.content_areas['generic'],
          view_model.areas
        )

        Workarea.config.content_areas['landing'] = %w(top bottom)
        model = Content.new(contentable: create_page(template: 'landing'))
        view_model = ContentViewModel.new(model)

        assert_equal(
          %w(top bottom),
          view_model.areas
        )
      end

      def test_new_block
        block_type = Content::BlockType.find(:text)

        model = Content.new(name: 'Checkout')
        view_model = ContentViewModel.new(
          model,
          new_block: { type_id: 'text', position: 3 }
        )

        assert(view_model.new_block?)
        assert_equal(:text, view_model.new_block.type_id)
        assert_equal(3, view_model.new_block.position)
        assert_equal(
          block_type.defaults.with_indifferent_access,
          view_model.new_block.data
        )

        preset = Content::Preset.create!(
          name: 'Foo Bar',
          type_id: :text,
          data: { text: 'preset custom text' }
        )

        view_model = ContentViewModel.new(
          model,
          new_block: { type_id: 'text', position: 3 },
          preset_id: preset.id.to_s
        )

        assert_equal(:text, view_model.new_block.type_id)
        assert_equal(3, view_model.new_block.position)
        assert_equal(
          preset.data.with_indifferent_access,
          view_model.new_block.data
        )
      end

      def test_content_area_in_new_block_draft
        block_type = Content::BlockType.find(:text)

        model = Content.new(name: 'Checkout')
        view_model = ContentViewModel.new(
          model,
          new_block: { type_id: 'text', position: 0 },
          area_id: 'test'
        )

        assert_equal('test', view_model.new_block_draft.area)
      end

      def test_open_graph_asset
        content = create_content
        view_model = ContentViewModel.wrap(content)

        og_asset = view_model.open_graph_asset
        assert(og_asset.open_graph_placeholder?)

        default_asset = create_asset(tag_list: 'og-default')
        view_model = ContentViewModel.wrap(content)
        assert_equal(default_asset, view_model.open_graph_asset)

        content.update_attributes(open_graph_asset_id: create_asset.id)
        view_model = ContentViewModel.wrap(content)
        og_asset = view_model.open_graph_asset

        refute(og_asset.open_graph_placeholder?)
      end

      def test_ambiguous_new_block_position
        content = create_content
        refute(ContentViewModel.wrap(content).ambiguous_new_block_position?)

        new_block_params = { type_id: 'text', position: 0 }
        view_model = ContentViewModel.wrap(content, new_block: new_block_params)
        refute(view_model.ambiguous_new_block_position?)

        view_model = ContentViewModel.wrap(content, new_block: new_block_params.merge(position: 1))
        assert(view_model.ambiguous_new_block_position?)

        release = create_release
        content.blocks.create!(type_id: 'text', position: 0, activate_with: release.id)
        content.blocks.create!(type_id: 'text', position: 1)

        view_model = ContentViewModel.wrap(content, new_block: new_block_params)
        refute(view_model.ambiguous_new_block_position?)

        view_model = ContentViewModel.wrap(content, new_block: new_block_params.merge(position: 1))
        assert(view_model.ambiguous_new_block_position?)

        view_model = ContentViewModel.wrap(content, new_block: new_block_params.merge(position: 2))
        refute(view_model.ambiguous_new_block_position?)
      end
    end
  end
end
