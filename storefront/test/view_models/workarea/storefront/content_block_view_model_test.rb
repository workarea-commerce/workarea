require 'test_helper'

module Workarea
  module Storefront
    class ContentBlockViewModelTest < TestCase
      class FooBarViewModel < ContentBlockViewModel
      end

      setup :set_config
      teardown :unset_config

      def set_config
        @current = Workarea.config.content_block_types
        Workarea.config.content_block_types = []
      end

      def unset_config
        Workarea.config.content_block_types = @current
      end

      def test_wrap
        Content.define_block_types do
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
        view_model = ContentBlockViewModel.new
        assert_equal(Content::Asset.image_placeholder, view_model.find_asset('asdf'))

        asset = create_asset
        assert_equal(asset, view_model.find_asset(asset.id))
      end

      def test_series
        Content.define_block_types do
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
    end
  end
end
