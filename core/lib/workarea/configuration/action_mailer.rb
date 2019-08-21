module Workarea
  module Configuration
    module ActionMailer
      extend self

      def load
        Rails.application.config.action_mailer.asset_host = Rails.application.config.action_controller.asset_host
        Rails.application.config.action_mailer.show_previews = !Rails.env.production?

        unless Rails.env.test? || Rails.env.development?
          if Rails.application.secrets.smtp_settings.present?
            Rails.application.config.action_mailer.raise_delivery_errors = true
            Rails.application.config.action_mailer.delivery_method = :smtp
            Rails.application.config.action_mailer.smtp_settings = smtp_settings
          end
        end
      end

      def smtp_settings
        Rails.application.secrets.smtp_settings.merge(enable_starttls_auto: false).symbolize_keys
      end
    end
  end
end
