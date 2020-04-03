require 'test_helper'

module Workarea
  class User
    class PasswordResetTest < TestCase
      def user
        @user ||= create_user(email: 'one@workarea.com')
      end

      def test_setup!
        2.times do
          PasswordReset.setup!(user.email)

          assert_equal(1, PasswordReset.count)
          assert_equal(user.id, PasswordReset.first.user_id)
        end

        two = create_user(email: 'two@workarea.com')
        PasswordReset.setup!('two@workarea.com')

        assert_equal(2, PasswordReset.count)
        assert_equal(two.id, PasswordReset.last.user_id)
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
