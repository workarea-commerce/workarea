module Workarea
  module Configuration
    module AssetHost
      extend self

      def load
        if Rails.application.config.action_controller.asset_host.blank?
          Rails.application.config.action_controller.asset_host = ENV['WORKAREA_ASSET_HOST']
        end
      end
    end
  end
end
