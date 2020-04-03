module Workarea
  class User
    class PasswordReset
      include ApplicationDocument
      include UrlToken

      belongs_to :user, class_name: 'Workarea::User', index: true

      index(
        { created_at: 1 },
        { expire_after_seconds: Workarea.config.password_reset_timeout }
      )

      def self.setup!(email)
        user = User.find_by_email(email)
        return nil unless user

        where(user_id: user.id).destroy_all
        create!(user: user)
      end

      def complete(new_password)
        if new_password.blank?
          errors.add(:password, I18n.t('errors.messages.blank'))
          return false
        end

        if user.update_attributes(password: new_password)
          destroy
        else
          user.errors.each do |attribute, error|
            errors.add(attribute, error)
          end
          false
        end
      end
    end
  end
end
