require 'test_helper'

module Workarea
  class Content
    class FieldTest < TestCase
      def test_default
        field = Field.new('foo', default: 'bar')
        assert_equal('bar', field.default)

        field = Field.new('foo', default: -> { rand(5) })
        assert(field.default.is_a?(Integer))
      end
    end
  end
end
