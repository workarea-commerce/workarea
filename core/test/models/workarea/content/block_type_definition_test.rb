require 'test_helper'

module Workarea
  class Content
    class BlockTypeDefinitionTest < TestCase
      setup :reset_config
      teardown :restore_config

      def reset_config
        @current = Configuration::ContentBlocks.types
        Configuration::ContentBlocks.types = []
      end

      def restore_config
        Configuration::ContentBlocks.types = @current
      end

      def test_constructs_a_list_of_blocks_based_on_the_dsl
        BlockTypeDefinition.new.instance_eval do
          block_type 'Foo' do
            icon 'workarea/admin/content_block_types/custom_foo_icon'
            description 'This is a foo content block type'
            tags %w(omg lol jk)
            view_model 'Workarea::Storefront::ContentBlocks::FooBarViewModel'

            fieldset 'Left Column' do
              field 'Hero Image', :asset, description: 'The image'
              field 'Link Text', :string
              field 'URL', :url
            end

            fieldset 'Right Column' do
              field 'Products', :products
            end
          end

          block_type 'Bar' do
            field 'Display', :string
          end
        end

        assert_equal(2, Configuration::ContentBlocks.types.length)
        results = Configuration::ContentBlocks.types

        assert_equal('Foo', results.first.name)
        assert_equal('workarea/admin/content_block_types/custom_foo_icon', results.first.icon)
        assert_equal('This is a foo content block type', results.first.description)
        assert_equal(%w(omg lol jk), results.first.tags)
        assert_equal('Workarea::Storefront::ContentBlocks::FooBarViewModel', results.first.view_model)
        assert_equal(2, results.first.fieldsets.length)

        assert_equal('Left Column', results.first.fieldsets.first.name)
        assert_equal(3, results.first.fieldsets.first.fields.length)
        assert_equal('Hero Image', results.first.fieldsets.first.fields.first.name)
        assert_equal(Workarea::Content::Fields::Asset, results.first.fieldsets.first.fields.first.class)
        assert_equal({ description: 'The image' }, results.first.fieldsets.first.fields.first.options)
        assert_equal('Link Text', results.first.fieldsets.first.fields.second.name)
        assert_equal(Workarea::Content::Fields::String, results.first.fieldsets.first.fields.second.class)
        assert_equal('URL', results.first.fieldsets.first.fields.third.name)
        assert_equal(Workarea::Content::Fields::Url, results.first.fieldsets.first.fields.third.class)

        assert_equal('Right Column', results.first.fieldsets.second.name)
        assert_equal(1, results.first.fieldsets.second.fields.length)
        assert_equal(Workarea::Content::Fields::Products, results.first.fieldsets.second.fields.first.class)
        assert_equal('Products', results.first.fieldsets.second.fields.first.name)

        assert_equal('Bar', results.second.name)
        assert_equal('workarea/admin/content_block_types/bar.svg', results.second.icon)
        assert_equal('Bar', results.second.description)
        assert_equal([], results.second.tags)
        assert_equal('Workarea::Storefront::ContentBlocks::BarViewModel', results.second.view_model)
        assert_equal('Settings', results.second.fieldsets.first.name)
        assert_equal(1, results.second.fieldsets.first.fields.length)
        assert_equal('Display', results.second.fieldsets.first.fields.first.name)
        assert_equal(Workarea::Content::Fields::String, results.second.fieldsets.first.fields.first.class)
      end

      def test_allows_redefining_on_blocks
        BlockTypeDefinition.new.instance_eval do
          block_type 'HTML' do
            description 'Raw HTML. Output exactly as input.'
            field 'HTML', :string, multi_line: true, default: 'Raw HTML Content'

            fieldset 'Praise Google' do
              field 'Keywords', :string
              field 'Description', :string
            end
          end

          block_type 'HTML' do
            description 'Foo'
            field 'HTML', :string, multi_line: false, default: 'Foo.'

            fieldset 'SEO Metadata', replaces: 'Praise Google' do
              field 'Keywords', :string
              field 'Description', :string
            end
          end
        end

        html = Content::BlockType.find(:html)
        fieldset_names = html.fieldsets.map(&:name)
        assert_equal('Foo', html.description)
        refute(html.fields.first.multi_line?)
        assert_equal('Foo.', html.fields.first.default)
        refute_includes(fieldset_names, 'Praise Google')
        assert_includes(fieldset_names, 'SEO Metadata')
      end

      def test_series
        BlockTypeDefinition.new.instance_eval do
          block_type 'Foo' do
            field 'Title', :string

            series 3 do
              field 'Hero Image', :asset, description: 'The image'
            end

            fieldset 'Right Column' do
              field 'Products', :products
            end
          end
        end

        result = Configuration::ContentBlocks.types.first

        assert_equal('Foo', result.name)
        assert_equal(5, result.fieldsets.length)

        assert_equal('1st', result.fieldsets.second.name)
        assert_equal(1, result.fieldsets.second.fields.length)
        assert_equal('Hero Image 1', result.fieldsets.second.fields.first.name)
        assert_equal(Content::Fields::Asset, result.fieldsets.second.fields.first.class)

        assert_equal('2nd', result.fieldsets.third.name)
        assert_equal(1, result.fieldsets.third.fields.length)
        assert_equal('Hero Image 2', result.fieldsets.third.fields.first.name)
        assert_equal(Content::Fields::Asset, result.fieldsets.third.fields.first.class)

        assert_equal('3rd', result.fieldsets.fourth.name)
        assert_equal(1, result.fieldsets.fourth.fields.length)
        assert_equal('Hero Image 3', result.fieldsets.fourth.fields.first.name)
        assert_equal(Content::Fields::Asset, result.fieldsets.fourth.fields.first.class)

        assert_equal('Right Column', result.fieldsets.fifth.name)
        assert_equal(1, result.fieldsets.fifth.fields.length)
        assert_equal('Products', result.fieldsets.fifth.fields.first.name)
        assert_equal(Content::Fields::Products, result.fieldsets.fifth.fields.first.class)
      end
    end
  end
end
