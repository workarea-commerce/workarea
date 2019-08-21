require 'test_helper'

module Workarea
  class User
    class RecentPasswordTest < TestCase
      def test_clean
        user = create_user
        passwords = []

        (Workarea.config.password_history_length + 1).times do
          passwords << RecentPassword.create!(
            user: user,
            password: SecureRandom.hex
          )
        end

        RecentPassword.clean(user)

        assert_equal(
          Workarea.config.password_history_length,
          user.recent_passwords.length
        )

        assert_raise(Mongoid::Errors::DocumentNotFound) { passwords.last.reload }
      end

      def test_save_password_digest
        password = 'Password!1'
        cost = if ActiveModel::SecurePassword.min_cost
                 BCrypt::Engine::MIN_COST
               else
                 BCrypt::Engine.cost
               end
        password_digest = BCrypt::Password.create(password, cost: cost).to_s
        user = User.new(
          email: 'admin@othersite.com',
          password_digest: password_digest
        )

        assert_nil(user.password)
        refute_nil(user.password_digest)
        assert_equal(password_digest, user.password_digest)
        assert(user.save!)
        refute_empty(user.recent_passwords)
        refute_nil(user.recent_passwords.first.password_digest)
        assert_equal(password_digest, user.recent_passwords.first.password_digest)
      end
    end
  end
end
