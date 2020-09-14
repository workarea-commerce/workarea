require 'test_helper'

module Workarea
  module Configuration
    module Administrable
      class FieldTest < TestCase
        def test_id
          assert_equal(:foo_bar, Field.new('Foo Bar', type: :string).id)
          assert_equal(:_billz, Field.new('$billz', type: :string).id)
        end

        def test_initialize
          field = Field.new(
            'Bar',
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

          field = Field.new('Bar', id: 'foobar', type: :string)

          assert_equal('Bar', field.name)
          assert_equal(:foobar, field.id)
        end

        def test_validate!
          field = Field.new('Bar', id: 'foobar', type: :string)
          assert(field.validate!)

          assert_raise(Field::Invalid) do
            Field.new('Qux', type: :fake).validate!
          end

          assert_raise(Field::Invalid) do
            Field.new('Dolla Billz', type: :string, id: '$billz').validate!
          end
        end

        def test_values
          field = Field.new('Foo', type: :string, values: %w(bar baz))
          assert_equal(%w(bar baz), field.values)

          field = Field.new('Foo', type: :string, values: -> { %w(bar baz) })
          assert_equal(%w(bar baz), field.values)
        end

        def test_values_type_class
          field = Field.new(
            'Bar',
            type: :string,
            values_type: :integer
          )

          assert_nil(field.values_type_class)

          field = Field.new(
            'Bar',
            type: :hash,
            values_type: :integer
          )

          assert_equal(Integer, field.values_type_class)
        end

        def test_overridden?
          field = Field.new('Foo', type: :string)
          refute(field.overridden?)

          Workarea.config.foo = 'bar'
          assert(field.overridden?)

          Workarea.config.foo = ''
          assert(field.overridden?)

          Workarea.config.delete(:foo)
          refute(field.overridden?)

          fieldset = Fieldset.new('Foo')
          field = Field.new('Bar', type: :string, fieldset: fieldset)
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

          fieldset = Fieldset.new('Foo', namespaced: false)
          field = Field.new('Bar', type: :string, fieldset: fieldset)
          refute(field.overridden?)

          Workarea.config.foo_bar = 'baz'
          refute(field.overridden?)

          Workarea.config.bar = 'baz'
          assert(field.overridden?)
        end

        def test_required?
          field = Field.new('Foo', type: :string)
          refute(field.required?)

          field = Field.new('Foo', type: :string, required: false)
          refute(field.required?)

          field = Field.new('Foo', type: :string, required: true)
          assert(field.required?)
        end
      end
    end
  end
end
