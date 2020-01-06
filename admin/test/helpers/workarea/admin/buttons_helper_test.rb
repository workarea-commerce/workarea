require 'test_helper'

module Workarea
  module Admin
    class ButtonsHelperTest < ViewTest
      def test_button_tag
        result = button_tag('Content', { data: { foo: 'bar' } })
        assert_match('Content', result)
        assert_match('data-foo="bar"', result)
        assert_match('data-disable="true"', result)

        result = button_tag({ data: { foo: 'bar' } })
        assert_match('data-foo="bar"', result)
        assert_match('data-disable="true"', result)

        result = button_tag({ data: { foo: 'bar', disable: false } })
        assert_match('data-foo="bar"', result)
        refute_match('data-disable="true"', result)

        result = button_tag('Content')
        assert_match('Content', result)
        assert_match('data-disable="true"', result)

        result = button_tag
        assert_match('data-disable="true"', result)

        result = button_tag({ data: { foo: 'bar' } }) { 'Content' }
        assert_match('Content', result)
        assert_match('data-foo="bar"', result)
        assert_match('data-disable="true"', result)

        result = button_tag { 'Content' }
        assert_match('Content', result)
        assert_match('data-disable="true"', result)
      end
    end
  end
end
