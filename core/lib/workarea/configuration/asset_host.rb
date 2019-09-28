module Workarea
  module Configuration
    module AssetHost
      extend self

      WORKAREA_ASSET_HOST = ENV['WORKAREA_ASSET_HOST']
      HEROKU_APP_NAME = ENV['HEROKU_APP_NAME']

      def load
        return unless Rails.application.config.action_controller.asset_host.blank?

        if WORKAREA_ASSET_HOST.present?
          Rails.application.config.action_controller.asset_host = WORKAREA_ASSET_HOST
        elsif HEROKU_APP_NAME.present?
          Rails.application.config.action_controller.asset_host = "//#{HEROKU_APP_NAME}.herokuapp.com"
        end
      end
    end
  end
end
