require 'test_helper'

module Workarea
  class Content
    class EmailTest < TestCase
      def test_find_by_type
        Email.create!(type: 'type1', content: 'foo')
        Email.create!(type: 'type2', content: 'bar')

        email = Email.find_by_type('type1')
        assert_equal('foo', email.content)
      end

      def test_name
        email = Email.create!(type: 'account_creation', content: 'foo')
        assert_equal('Account Creation', email.name)
      end
    end
  end
end
