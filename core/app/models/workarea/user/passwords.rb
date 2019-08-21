module Workarea
  class User
    module Passwords
      extend ActiveSupport::Concern
      include ActiveModel::SecurePassword

      included do
        field :password_digest, type: String
        field :password_changed_at, type: Time

        has_secure_password
        has_many :recent_passwords, class_name: 'Workarea::User::RecentPassword'

        validates :password, password: { strength: :required_password_strength }
        validate :password_not_recent, if: :password_digest_changed?

        before_save :mark_password_change, if: :password_digest_changed?
        after_save :save_recent_password, if: :password_digest_changed?
        after_save :cleanup_passwords, if: :password_digest_changed?
      end

      def required_password_strength
        admin? ? :strong : Workarea.config.password_strength
      end

      def force_password_change?
        return false unless admin?
        return false if password_changed_at.blank?

        password_changed_at <= Workarea.config.password_lifetime.ago
      end

      private

      def password_not_recent
        return unless admin?

        if invalid_passwords.any? { |p| p.authenticate(@password) }
          message = I18n.t(
            'workarea.user.password_not_recent',
            length: Workarea.config.password_history_length
          )

          errors.add(:password, message)
        end
      end

      def invalid_passwords
        recent_passwords.desc(:created_at).from(1)
      end

      def mark_password_change
        self.password_changed_at = Time.current
      end

      def save_recent_password
        # Building this off the relation causes an infinite loop of calling
        # save on the User. TODO open a Mongoid PR before v3
        RecentPassword.create!(user_id: id, password_digest: password_digest)
      end

      def cleanup_passwords
        RecentPassword.clean(self)
      end
    end
  end
end
