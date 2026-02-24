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

        if user.update(password: new_password)
          destroy
        else
          if errors.respond_to?(:merge!)
            errors.merge!(user.errors)
          else
            # Rails 7 yields ActiveModel::Error objects; older Rails yields
            # [attribute, message] pairs.
            user.errors.each do |error|
              if error.respond_to?(:attribute) && error.respond_to?(:message)
                errors.add(error.attribute, error.message)
              else
                attribute, message = error
                errors.add(attribute, message)
              end
            end
          end

          false
        end
      end
    end
  end
end
