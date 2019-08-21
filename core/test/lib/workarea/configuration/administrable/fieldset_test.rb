require 'test_helper'

module Workarea
  module Configuration
    module Administrable
      class FieldsetTest < TestCase
        def test_id
          assert_equal(:foo_bar, Fieldset.new('Foo Bar').id)
          assert_equal(:_billz, Fieldset.new('$billz').id)
        end

        def test_field
          fieldset = Fieldset.new('Foo')

          fieldset.field 'Bar',
            type: :string,
            default: 'baz',
            values: %w(bax qux),
            description: 'this is a test field'

          assert_equal(1, fieldset.fields.size)

          field = fieldset.fields.first
          assert_equal('Bar', field.name)
          assert_equal(:bar, field.id)
          assert_equal(:string, field.type)
          assert_equal('baz', field.default)
          assert_equal(%w(bax qux), field.values)
          assert_equal('this is a test field', field.description)

          fieldset.field 'Bar', override: true, type: :symbol, default: :baz

          assert_equal(1, fieldset.fields.size)

          field = fieldset.fields.first
          assert_equal('Bar', field.name)
          assert_equal(:bar, field.id)
          assert_equal(:symbol, field.type)
          assert_equal(:baz, field.default)
          assert_nil(field.values)
          assert_nil(field.description)

          fieldset.field 'Bar', values: %i(baz qux), default: :qux

          assert_equal(1, fieldset.fields.size)

          field = fieldset.fields.first
          assert_equal('Bar', field.name)
          assert_equal(:bar, field.id)
          assert_equal(:symbol, field.type)
          assert_equal(:qux, field.default)
          assert_equal(%i(baz qux), field.values)
          assert_nil(field.description)

          fieldset.field 'Bar', encrypted: true
          assert(Rails.application.config.filter_parameters.include?(:foo_bar))

          assert_raise(Field::Invalid) do
            fieldset.field 'Qux', type: :fake
          end

          assert_raise(Field::Invalid) do
            fieldset.field 'Dolla Billz', type: :string, id: '$billz'
          end
        end

        def test_find_field
          fieldset = Fieldset.new('Foo')
          fieldset.field 'Bar', type: :string

          assert_equal(:bar, fieldset.find_field('bar').id)
          assert_equal(:bar, fieldset.find_field(:bar).id)
          assert_nil(fieldset.find_field(:baz))
        end
      end
    end
  end
end
