require 'test_helper'

module Workarea
  module Admin
    class SettingsHelperTest < ViewTest
      include ERB::Util

      def test_sanitize_config_value
        assert(sanitize_config_value([]).blank?)
        assert(sanitize_config_value('').blank?)
        assert(sanitize_config_value(nil).blank?)

        assert_equal(
          '<code class="code code--block">foo</code>',
          sanitize_config_value('foo')
        )

        assert_equal(
          '<code class="code code--block">:foo</code>',
          sanitize_config_value(':foo')
        )

        assert_equal(
          '<code class="code code--block">3</code>',
          sanitize_config_value(3)
        )

        assert_equal(
          '<code class="code code--block">false</code>',
          sanitize_config_value(false)
        )

        assert_equal(
          '<code class="code code--block">30 days</code>',
          sanitize_config_value(30.days)
        )

        assert_match(
          /pre.*expandable.*code.*{\n.*foo.*bar.*\n.*}/,
          sanitize_config_value({ foo: 'bar' })
        )

        assert_match(
          /pre.*expandable.*code.*\[\n.*foo.*\n.*bar.*\n.*\]/,
          sanitize_config_value(['foo', 'bar'])
        )

        assert_match(
          /pre.*expandable.*code.*\[\n.*foo.*\n.*bar.*\n.*\]/,
          sanitize_config_value(SwappableList.new(['foo', 'bar']))
        )
      end
    end
  end
end
