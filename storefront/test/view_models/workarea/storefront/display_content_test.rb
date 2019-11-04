require 'test_helper'

module Workarea
  module Storefront
    class DisplayContentTest < TestCase
      class ContentableModel
        include ApplicationDocument
        include Contentable
        field :name, type: String
      end

      class DisplayContentViewModel < ApplicationViewModel
        include DisplayContent
        attr_accessor :content_lookup_override

        def content_lookup
          @content_lookup_override.presence || super
        end
      end

      def test_browser_title_uses_content_browser_title
        model = ContentableModel.create!(name: 'Ben')
        view_model = DisplayContentViewModel.wrap(model)
        assert_equal('Ben', view_model.browser_title)

        content = Content.for(model)
        content.update_attributes!(browser_title: 'Foo')

        view_model = DisplayContentViewModel.wrap(model)
        assert_equal('Foo', view_model.browser_title)
      end

      def test_meta_description
        model = ContentableModel.create!
        view_model = DisplayContentViewModel.wrap(model)

        assert_equal(
          t(
            'workarea.storefront.layouts.default_meta_description',
            site_name: Workarea.config.site_name
          ),
          view_model.meta_description
        )

        content = Content.for(model)
        content.update_attributes!(meta_description: 'Foo')

        view_model = DisplayContentViewModel.wrap(model)
        assert_equal('Foo', view_model.meta_description)
      end

      def test_using_content_lookup_to_allow_overrides
        model = ContentableModel.create!(name: 'Ben')
        model_content = Content.for(model)
        override_content = Content.for('Foo')

        assert_equal(model_content, DisplayContentViewModel.wrap(model).content)

        view_model = DisplayContentViewModel.wrap(model)
        view_model.content_lookup_override = 'Foo'
        assert_equal(override_content, view_model.content)
      end

      def test_uses_only_active_blocks_in_content_for
        model = ContentableModel.create!(name: 'Ben')
        content = Content.for(model)
        active = content.blocks.create!(area: 'foo', type: 'html')
        content.blocks.create!(area: 'foo', type: 'html', active: false)

        view_model = DisplayContentViewModel.wrap(model)
        assert_equal([active.id], view_model.content_blocks_for('foo').map(&:id))
        assert_instance_of(
          ContentBlockViewModel,
          view_model.content_blocks_for('foo').first
        )
      end

      def test_uses_only_active_default_blocks_in_content_blocks
        model = ContentableModel.create!(name: 'Ben')
        content = Content.for(model)
        active = content.blocks.create!(area: 'default', type: 'html')
        content.blocks.create!(area: 'foo', type: 'html', active: false)
        content.blocks.create!(type: 'html', active: false)

        view_model = DisplayContentViewModel.wrap(model)
        assert_equal([active.id], view_model.content_blocks.map(&:id))
        assert_instance_of(ContentBlockViewModel, view_model.content_blocks.first)
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
    end
  end
end
