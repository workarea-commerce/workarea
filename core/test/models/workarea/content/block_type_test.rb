require 'test_helper'

module Workarea
  class Content
    class BlockTypeTest < TestCase
      def test_config
        block_type = BlockType.new('Foo')
        block_type.instance_eval do
          width 960
          height 470
        end

        assert_equal({ width: 960, height: 470 }, block_type.config)
      end

      def test_defaults
        block_type = BlockType.new('Foo')
        block_type.instance_eval do
          field :foo, :string, default: 'foo'
          field :bar, :string, default: 'bar'
        end

        assert_equal({ foo: 'foo', bar: 'bar' }, block_type.defaults)
      end

      def test_field
        block_type = BlockType.new('Foo')
        block_type.instance_eval do
          field :foo, :string, default: 'foo'
        end

        assert(block_type.fieldsets.first.instance_of?(Fieldset))
        assert_equal('Settings', block_type.fieldsets.first.name)
      end

      def test_series
        block_type = BlockType.new('Foo')
        block_type.instance_eval do
          field :foo, :string, default: 'foo'

          series 3 do
            field :bar, :string, default: 'bar'
            field :baz, :string, default: 'bar'
          end
        end

        assert_equal(3, block_type.series.length)
        assert(block_type.series.first.instance_of?(Fieldset))
        assert('1st', block_type.series.first.name)
      end

      def test_fieldset
        block_type = BlockType.new('Foo')
        block_type.instance_eval do
          fieldset 'Foo Fields' do
            field :foo, :string, default: 'foo'
          end

          fieldset 'Bar Fields', replaces: 'Foo Fields' do
            field :bar, :string, default: 'foo'
            field :baz, :string, default: 'bar'
          end
        end

        assert_equal(1, block_type.fieldsets.count)
        fieldset = block_type.fieldsets.first
        field_names = fieldset.fields.map(&:name)
        refute_includes(field_names, :foo)
        assert_includes(field_names, :bar)
        assert_includes(field_names, :baz)
        assert_equal('Bar Fields', fieldset.name)
      end

      def test_remove_fieldset
        block_type = BlockType.new('Foo')
        block_type.instance_eval do
          fieldset 'Foo Fields' do
            field :foo, :string, default: 'foo'
          end

          fieldset 'Bar Fields' do
            field :bar, :string
          end

          remove_fieldset 'Foo Fields'
        end

        fieldsets = block_type.fieldsets.map(&:name)

        refute_includes(fieldsets, 'Foo Fields')
        assert_includes(fieldsets, 'Bar Fields')
      end
    end
  end
end
