require 'test_helper'

module Workarea
  module Configuration
    class ParamsTest < TestCase
      def test_to_h
        Workarea.config.admin_definition = Administrable::Definition.new
        Workarea::Configuration.define_fields do
          field 'foo', type: :string, required: false
          field 'bar', type: :string, default: 'test'
          field 'baz', type: :string, required: false, default: 'baz'

          field 'foo_hash', type: :hash, values_type: :integer, required: false
          field 'foo_array', type: :array, values_type: :integer, required: false
          field 'bar_array', type: :array, required: false
          field 'baz_duration', type: :duration, required: false
        end

        params = {
          foo: 'string value',
          bar: nil,
          baz: '',
          foo_hash: ['one', '1', 'two', '', '', ''],
          foo_array: '1,2,3',
          bar_array: 'one, two, three',
          baz_duration: %w(20 minutes)
        }

        result = Params.new(params).to_h
        assert_equal('string value', result[:foo])
        assert_equal('test', result[:bar])
        assert_equal('', result[:baz])
        assert_equal({ 'one' => 1 }, result[:foo_hash])
        assert_equal([1, 2, 3], result[:foo_array])
        assert_equal(%w(one two three), result[:bar_array])
        assert_equal(20.minutes, result[:baz_duration])
      end
    end
  end
end
