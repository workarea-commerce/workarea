require 'test_helper'

module Workarea
  class ConstantsTest < TestCase
    class Foo; end
    class Bar; end

    teardown { Constants.reset!(:test) }

    def test_remembers_the_registration
      Constants.register(:test, Foo)
      Constants.register(:test, Bar)

      results = Constants.find(:test)
      assert_includes(results, Foo)
      assert_includes(results, Bar)
    end

    def test_does_not_duplicate_registration
      Constants.register(:test, Foo)
      Constants.register(:test, Foo)

      assert_equal([Foo], Constants.find(:test))
    end
  end
end
