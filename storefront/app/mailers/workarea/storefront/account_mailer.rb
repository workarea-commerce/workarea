module Workarea
  module Storefront
    class AccountMailer < Storefront::ApplicationMailer
      include TransactionalMailer

      skip_after_action :check_if_enabled, only: :password_reset

      def creation(user_id)
        @user = User.find(user_id)
        @content = Content::Email.find_content('account_creation')
        mail(to: @user.email, subject: t('workarea.storefront.email.account_created.subject'))
      end

      def password_reset(password_reset_id)
        @reset = User::PasswordReset.find(password_reset_id)
        @content = Content::Email.find_content('password_reset')
        mail(to: @reset.user.email, subject: t('workarea.storefront.email.password_reset.subject'))
      end
    end
  end
end
