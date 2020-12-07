require 'test_helper'

module Workarea
  module Configuration
    module Administrable
      class FieldTest < TestCase
        def test_id
          assert_equal(:foo_bar, Field.new('Foo Bar', type: :string).id)
          assert_equal(:_billz, Field.new('$billz', type: :string).id)
        end

        def test_name
          assert_equal('Foo Bar', Field.new('foo_bar', type: :string).name)
          assert_equal('Foo Bar', Field.new(:foo_bar, type: :string).name)
        end

        def test_initialize
          field = Field.new(
            :bar,
            type: :string,
            default: 'baz',
            values: %w(bax qux),
            description: 'this is a test field'
          )

          assert_equal('Bar', field.name)
          assert_equal(:bar, field.id)
          assert_equal(:string, field.type)
          assert_equal('baz', field.default)
          assert_equal(%w(bax qux), field.values)
          assert_equal('this is a test field', field.description)

          field = Field.new(:bar, name: 'Foo Bar', type: :string)

          assert_equal('Foo Bar', field.name)
          assert_equal(:bar, field.id)
        end

        def test_validate!
          field = Field.new(:bar, id: 'foobar', type: :string, default: 'bar')
          assert(field.validate!)

          assert_raise(Field::Invalid) do
            Field.new(:qux, type: :fake).validate!
          end

          assert_raise(Field::Invalid) do
            Field.new('Qoo', type: :string, required: true, default: nil).validate!
          end
        end

        def test_values
          field = Field.new(:foo, type: :string, values: %w(bar baz))
          assert_equal(%w(bar baz), field.values)

          field = Field.new(:foo, type: :string, values: -> { %w(bar baz) })
          assert_equal(%w(bar baz), field.values)
        end

        def test_values_type_class
          field = Field.new(
            :bar,
            type: :string,
            values_type: :integer
          )

          assert_nil(field.values_type_class)

          field = Field.new(
            :bar,
            type: :hash,
            values_type: :integer
          )

          assert_equal(Integer, field.values_type_class)

          field = Field.new(
            'Bar',
            type: :array,
            values_type: :integer
          )

          assert_equal(Integer, field.values_type_class)
        end

        def test_overridden?
          field = Field.new(:foo, type: :string)
          refute(field.overridden?)

          Workarea.config.foo = 'bar'
          assert(field.overridden?)

          Workarea.config.foo = ''
          assert(field.overridden?)

          Workarea.config.delete(:foo)
          refute(field.overridden?)

          fieldset = Fieldset.new(:foo)
          field = Field.new(:bar, type: :string, fieldset: fieldset)
          refute(field.overridden?)

          Workarea.config.foo_bar = 'baz'
          assert(field.overridden?)

          Workarea.config.foo_bar = ''
          assert(field.overridden?)

          Workarea.config.delete(:foo_bar)
          refute(field.overridden?)

          Workarea.config.bar = 'baz'
          refute(field.overridden?)

          Workarea.config.delete(:bar)

          fieldset = Fieldset.new(:foo, namespaced: false)
          field = Field.new(:bar, type: :string, fieldset: fieldset)
          refute(field.overridden?)

          Workarea.config.foo_bar = 'baz'
          refute(field.overridden?)

          Workarea.config.bar = 'baz'
          assert(field.overridden?)
        end

        def test_required?
          field = Field.new(:foo, type: :string, default: 'foo')
          assert(field.required?)

          field = Field.new(:foo, type: :string, required: false)
          refute(field.required?)

          field = Field.new(:foo, type: :string, default: 'foo', required: true)
          assert(field.required?)
        end
      end
    end
  end
end
