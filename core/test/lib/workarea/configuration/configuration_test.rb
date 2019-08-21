require 'test_helper'

module Workarea
  module Configuration
    class AdministrableOptionsTest < TestCase
      def test_method_missing
        instance = Admin.instance
        config = AdministrableOptions.new

        instance.update(email_to: 'test@workarea.com')
        assert_equal('test@workarea.com', config.email_to)

        config.email_to = 'other@workarea.com'
        assert_equal('other@workarea.com', config.email_to)

        assert_nil(config.fake_key)
      end
    end
  end
end
