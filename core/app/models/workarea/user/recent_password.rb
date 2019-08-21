module Workarea
  class User
    class RecentPassword
      include ApplicationDocument
      include ActiveModel::SecurePassword

      field :password_digest, type: String
      belongs_to :user, class_name: 'Workarea::User', index: true
      has_secure_password validations: false

      scope :by_newest, -> { desc(:created_at) }

      def self.clean(user)
        limit = Workarea.config.password_history_length

        if user.recent_passwords.length > limit
          user
            .recent_passwords
            .by_newest
            .to_a
            .first(user.recent_passwords.length - limit)
            .each(&:delete)
        end
      end
    end
  end
end
