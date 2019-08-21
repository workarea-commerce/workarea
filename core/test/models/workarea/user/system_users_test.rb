require 'test_helper'

module Workarea
  class User
    class SystemUsersTest < TestCase
      def test_creation
        assert(User.console.is_a?(User))
        assert(User.console.system?)
        assert(User.console == User.console)
        refute(create_user.system?)
      end
    end
  end
end
