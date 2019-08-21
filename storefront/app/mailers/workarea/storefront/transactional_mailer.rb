module Workarea
  module Storefront
    module TransactionalMailer
      extend ActiveSupport::Concern

      included do
        after_action :check_if_enabled
      end

      def check_if_enabled
        if mail.present?
          mail.perform_deliveries = Workarea.config.send_transactional_emails
        end
      end
    end
  end
end
