require 'test_helper'

module Workarea
  module Admin
    class SettingsHelperTest < ViewTest
      include ERB::Util

      def test_sanitize_config_value
        assert(sanitize_config_value([]).blank?)
        assert(sanitize_config_value(Object.new).blank?)

        assert_equal(
          '<code class="code code--block">foo</code>',
          sanitize_config_value('foo')
        )

        assert_equal(
          '<code class="code code--block">:foo</code>',
          sanitize_config_value(':foo')
        )

        assert_match(
          /pre.*expandable.*code.*{\n.*foo.*bar.*\n.*}/,
          sanitize_config_value({ foo: 'bar' })
        )

        assert_match(
          /pre.*expandable.*code.*\[\n.*foo.*\n.*bar.*\n.*\]/,
          sanitize_config_value(['foo', 'bar'])
        )
      end
    end
  end
end
