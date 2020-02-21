require 'test_helper'

module Workarea
  module Storefront
    class ContentBlockViewModelTest < TestCase
      class FooBarViewModel < ContentBlockViewModel
      end

      setup :set_config
      teardown :unset_config

      def set_config
        @current = Configuration::ContentBlocks.types
        Configuration::ContentBlocks.types = []
      end

      def unset_config
        Configuration::ContentBlocks.types = @current
      end

      def test_wrap
        Content::BlockTypeDefinition.define do
          block_type 'Bar' do
            view_model FooBarViewModel.name
            field 'Display', :string
          end
        end

        block = Content::Block.new(type_id: 'bar')

        assert(
          ContentBlockViewModel
            .wrap(block)
            .instance_of?(FooBarViewModel)
        )
      end

      def test_find_asset
        Content::BlockTypeDefinition.define do
          block_type 'Bar' do
            view_model FooBarViewModel.name
            field 'Image', :asset
          end
        end

        block = Content::Block.new(type_id: 'bar')

        view_model = ContentBlockViewModel.new(block)
        assert_equal(Content::Asset.image_placeholder, view_model.find_asset('asdf'))

        asset = create_asset
        assert_equal(asset, view_model.find_asset(asset.id))
      end

      def test_series
        Content::BlockTypeDefinition.define do
          block_type 'Bar' do
            view_model FooBarViewModel.name

            field 'Title', :string, default: 'The Title'

            series 3 do
              field 'Display', :string, default: 'Hi'
            end
          end
        end

        block_type = Content::BlockType.find(:bar)

        block = Content::Block.new(type: 'bar')
        view_model = ContentBlockViewModel.wrap(block, foo: 'bar')
        assert_equal(0, view_model.series.length)

        block = Content::Block.new(type: 'bar', data: block_type.defaults)
        view_model = ContentBlockViewModel.wrap(block, foo: 'bar')
        assert_equal('The Title', view_model.data[:title])
        assert_equal(3, view_model.series.length)
        assert_equal('The Title', view_model.series.first.data[:title])
        assert_equal('Hi', view_model.series.first.data[:display])
        assert_equal(view_model.series, view_model.series.first.series)

        block = Content::Block.new(
          type: 'bar',
          data: { display_1: 'Yo', display_2: 'Hey', display_3: 'Sup' }
        )

        view_model = ContentBlockViewModel.wrap(block, foo: 'bar')
        assert_equal(3, view_model.series.length)
        assert_equal('Yo', view_model.series.first.data[:display])
        assert_equal('Hey', view_model.series.second.data[:display])
        assert_equal('Sup', view_model.series.third.data[:display])
      end

      def test_assets
        asset_1 = create_asset
        asset_2 = create_asset

        Content::BlockTypeDefinition.define do
          block_type 'Foo' do
            view_model FooBarViewModel.name

            field 'Gralph', :asset
            field 'Corge', :asset
          end
        end

        Content::BlockTypeDefinition.define do
          block_type 'Bar' do
            view_model FooBarViewModel.name

            field 'Gralph', :asset, default: asset_1.id
            field 'Corge', :asset
          end
        end

        Content::BlockTypeDefinition.define do
          block_type 'Baz' do
            view_model FooBarViewModel.name

            field 'Gralph', :asset, default: asset_1.id
            field 'Corge', :asset, default: asset_2.id
          end
        end

        Content::BlockTypeDefinition.define do
          block_type 'Qux' do
            view_model FooBarViewModel.name

            field 'Gralph', :asset, default: asset_1.id
            field 'Corge', :asset, default: 'foobar'
          end
        end

        block_type = Content::BlockType.find(:foo)
        block = Content::Block.new(type: 'foo', data: block_type.defaults)
        view_model = ContentBlockViewModel.wrap(block)

        assert_empty(view_model.assets)

        block_type = Content::BlockType.find(:bar)
        block = Content::Block.new(type: 'bar', data: block_type.defaults)
        view_model = ContentBlockViewModel.wrap(block)

        assert_equal(1, view_model.assets.size)
        assert_equal(asset_1.id.to_s, view_model.assets.keys.first)
        assert_equal(asset_1, view_model.assets.values.first)

        block_type = Content::BlockType.find(:baz)
        block = Content::Block.new(type: 'baz', data: block_type.defaults)
        view_model = ContentBlockViewModel.wrap(block)

        assert_equal(2, view_model.assets.size)
        assert_equal(asset_1, view_model.assets.values.first)
        assert_equal(asset_2, view_model.assets.values.last)

        block_type = Content::BlockType.find(:qux)
        block = Content::Block.new(type: 'qux', data: block_type.defaults)
        view_model = ContentBlockViewModel.wrap(block)

        assert_equal(2, view_model.assets.size)
        assert_equal(asset_1, view_model.assets.values.first)
        assert_equal(Content::Asset.image_placeholder, view_model.assets.values.last)
      end

      def test_asset_alt_text
        asset = create_asset(alt_text: 'Foo Bar')

        Content::BlockTypeDefinition.define do
          block_type 'Foo' do
            view_model FooBarViewModel.name

            field 'Image', :asset, default: asset.id, alt_field: 'Alt text field'
            field 'Alt Text Field', :string, default: 'Bar Baz'
          end
        end

        block_type = Content::BlockType.find(:foo)
        block = Content::Block.new(type: 'foo', data: block_type.defaults)
        view_model = ContentBlockViewModel.wrap(block)

        assert_equal(1, view_model.asset_alt_text.size)
        assert_equal(:alt_text_field, view_model.asset_alt_text.keys.first)
        assert_equal('Foo Bar', view_model.asset_alt_text[:alt_text_field])
      end

      def test_locals_contain_alt_text
        asset = create_asset
        asset_with_alt = create_asset(alt_text: 'Foo Bar')

        Content::BlockTypeDefinition.define do
          block_type 'Foo' do
            view_model FooBarViewModel.name

            # Image without alt text
            field 'Image 1', :asset, default: asset.id, alt_field: 'Alt text 1'
            field 'Alt text 1', :string

            # Image with alt text from asset
            field 'Image 2', :asset, default: asset_with_alt.id, alt_field: 'Alt text 2'
            field 'Alt text 2', :string

            # Image with alt text overridden by field
            field 'Image 3', :asset, default: asset_with_alt.id, alt_field: 'Alt text 3'
            field 'Alt text 3', :string, default: 'Bar Baz'
          end
        end

        block_type = Content::BlockType.find(:foo)
        block = Content::Block.new(type: 'foo', data: block_type.defaults)
        view_model = ContentBlockViewModel.wrap(block)

        assert_nil(view_model.locals[:alt_text_1])
        assert_equal('Foo Bar', view_model.locals[:alt_text_2])
        assert_equal('Bar Baz', view_model.locals[:alt_text_3])
      end
    end
  end
end
