module Workarea
  module Configuration
    module ErrorHandling
      extend self

      def load
        Rails.application.config.action_dispatch.rescue_responses['Workarea::InvalidDisplay'] = :not_found

        unless Rails.application.config.consider_all_requests_local
          Rails.application.config.exceptions_app = Storefront::Engine.routes
        end
      end
    end
  end
end
