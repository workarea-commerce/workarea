module Workarea
  class User
    module Login
      extend ActiveSupport::Concern

      included do
        field :ip_address, type: String
        field :user_agent, type: String
        field :last_login_at, type: Time
        field :last_login_attempt_at, type: Time
        field :failed_login_count, type: Integer, default: 0
      end

      module ClassMethods
        def find_for_login(email, password)
          return nil if email.blank? || password.blank?

          user = find_by_email(email)
          return nil unless user

          if user.authenticate(password)
            user
          else
            user.login_failure!
            nil
          end
        end

        def login_locked?(email)
          user = find_by_email(email)
          return false unless user

          user.login_locked?
        end
      end

      def login_success!
        self.last_login_at = Time.current
        self.failed_login_count = 0
        mark_login_attempt
      end

      def login_failure!
        self.failed_login_count += 1
        mark_login_attempt
      end

      def login_locked?
        exceeded_login_failure_limit? &&
          last_login_attempt_at >= Workarea.config.lockout_period.ago
      end

      def unlock_login!
        update!(failed_login_count: 0)
      end

      def update_login!(request)
        update_attributes!(
          ip_address: request.ip,
          user_agent: request.user_agent
        )
      end

      def valid_logged_in_request?(request)
        (ip_address.blank? || ip_address == request.ip) &&
          (user_agent.blank? || user_agent == request.user_agent)
      end

      private

      def exceeded_login_failure_limit?
        failed_login_count >= Workarea.config.allowed_login_attempts
      end

      def mark_login_attempt
        update_attribute(:last_login_attempt_at, Time.current)
      end
    end
  end
end
