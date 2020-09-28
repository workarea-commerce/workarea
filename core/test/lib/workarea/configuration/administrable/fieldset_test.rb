require 'test_helper'

module Workarea
  module Configuration
    module Administrable
      class FieldsetTest < TestCase
        def test_id
          assert_equal(:foo_bar, Fieldset.new('Foo Bar').id)
          assert_equal(:_billz, Fieldset.new('$billz').id)
        end

        def test_name
          assert_equal('Foo Bar', Fieldset.new('foo_bar').name)
          assert_equal('Foo Bar', Fieldset.new(:foo_bar).name)
        end

        def test_field
          fieldset = Fieldset.new(:foo)

          fieldset.field :bar,
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

          fieldset.field :bar, override: true, type: :symbol, default: :baz

          assert_equal(1, fieldset.fields.size)

          field = fieldset.fields.first
          assert_equal('Bar', field.name)
          assert_equal(:bar, field.id)
          assert_equal(:symbol, field.type)
          assert_equal(:baz, field.default)
          assert_nil(field.values)
          assert_nil(field.description)

          fieldset.field :bar, values: %i(baz qux), default: :qux

          assert_equal(1, fieldset.fields.size)

          field = fieldset.fields.first
          assert_equal('Bar', field.name)
          assert_equal(:bar, field.id)
          assert_equal(:symbol, field.type)
          assert_equal(:qux, field.default)
          assert_equal(%i(baz qux), field.values)
          assert_nil(field.description)

          fieldset.field :bar, encrypted: true, required: false
          assert(Rails.application.config.filter_parameters.include?(:foo_bar))

          assert_raise(Field::Invalid) do
            fieldset.field :qoo, type: :fake, required: false
          end

          assert_raise(Field::Invalid) do
            fieldset.field :qux, type: :string, required: true, default: nil
          end
        end

        def test_find_field
          fieldset = Fieldset.new(:foo)
          fieldset.field :bar, type: :string, required: false

          assert_equal(:bar, fieldset.find_field('bar').id)
          assert_equal(:bar, fieldset.find_field(:bar).id)
          assert_nil(fieldset.find_field(:baz))
        end
      end
    end
  end
end
