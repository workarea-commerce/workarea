require 'test_helper'

module Workarea
  module Configuration
    module Administrable
      class DefinitionTest < TestCase
        def test_fieldset
          definition = Definition.new

          assert_equal(1, definition.fieldsets.size)

          fieldset = definition.fieldsets.first
          assert_equal(:application, fieldset.id)
          assert_equal(0, fieldset.fields.size)

          definition.fieldset(:foo_bar) do
            field :baz, type: :string, default: 'baz'
          end

          assert_equal(2, definition.fieldsets.size)

          fieldset = definition.fieldsets.last
          assert_equal(:foo_bar, fieldset.id)
          assert_equal('Foo Bar', fieldset.name)
          assert_equal(1, fieldset.fields.size)
          assert_equal(:baz, fieldset.fields.first.id)
          assert_equal('Baz', fieldset.fields.first.name)
          assert_equal(:string, fieldset.fields.first.type)

          definition.fieldset(:foo_bar) do
            field :qux, type: :array, default: []
          end

          assert_equal(2, definition.fieldsets.size)

          fieldset = definition.fieldsets.last
          assert_equal(:foo_bar, fieldset.id)
          assert_equal('Foo Bar', fieldset.name)
          assert_equal(2, fieldset.fields.size)
          assert_equal(:qux, fieldset.fields.last.id)
          assert_equal('Qux', fieldset.fields.last.name)
          assert_equal(:array, fieldset.fields.last.type)
          assert_equal([], fieldset.fields.last.default)

          definition.fieldset(:foo_bar, override: true) do
            field :boo, type: :integer, default: 888
          end

          fieldset = definition.fieldsets.last
          assert_equal(:foo_bar, fieldset.id)
          assert_equal(1, fieldset.fields.size)
          assert_equal(:boo, fieldset.fields.first.id)
          assert_equal(:integer, fieldset.fields.first.type)
          assert_equal(888, fieldset.fields.first.default)
        end

        def test_find_fieldset
          definition = Definition.new

          assert_equal(:application, definition.find_fieldset('application').id)
          assert_equal(:application, definition.find_fieldset(:application).id)

          definition.fieldset(:foo_bar) do
            field :baz, type: :string, default: 'baz'
          end

          assert_equal(:foo_bar, definition.find_fieldset('foo_bar').id)
          assert_equal(:foo_bar, definition.find_fieldset(:foo_bar).id)
          assert_nil(definition.find_fieldset('baz'))
        end
      end
    end
  end
end
