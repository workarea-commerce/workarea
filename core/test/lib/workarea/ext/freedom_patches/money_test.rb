require 'test_helper'

module Workarea
  class MoneyTest < TestCase
    def test_mongoize_returns_nil_for_blank_values
      assert_nil(Money.mongoize(''))
      assert_nil(Money.mongoize(' '))
      assert_nil(Money.mongoize(nil))
    end
  end
end
