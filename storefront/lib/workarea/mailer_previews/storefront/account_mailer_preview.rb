module Workarea
  module Storefront
    class AccountMailerPreview < ActionMailer::Preview
      def creation
        user_id = User.first.id
        AccountMailer.creation(user_id)
      end

      def password_reset
        user = User.first
        reset = User::PasswordReset.setup!(user.email)
        AccountMailer.password_reset(reset.id)
      end
    end
  end
end
