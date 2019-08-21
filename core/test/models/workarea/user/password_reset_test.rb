require 'test_helper'

module Workarea
  class User
    class PasswordResetTest < TestCase
      def user
        @user ||= create_user
      end

      def test_setup!
        PasswordReset.setup!(user.email)

        assert_equal(1, PasswordReset.count)
        assert_equal(user.id, PasswordReset.first.user_id)
      end

      def test_complete
        reset = PasswordReset.create!(user: user)
        reset.complete('')

        assert(reset.errors[:password].present?)

        reset = PasswordReset.create!(user: user)
        reset.complete('1')

        assert(reset.errors[:password].present?)
      end
    end
  end
end
