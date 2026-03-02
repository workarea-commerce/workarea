module Workarea
  module Storefront
    class ApplicationMailer < Workarea::ApplicationMailer
      layout 'workarea/storefront/email'
      helper_method :path_to_url
      before_action :set_config

      helper ActionView::Helpers::AssetUrlHelper
      helper Workarea::DetailsHelper
      helper Workarea::Storefront::SchemaOrgHelper

      def path_to_url(path)
        protocol = Rails.application.config.force_ssl ? 'https' : 'http'
        "#{protocol}://#{Workarea.config.host}/#{path.sub(/^\//, '')}"
      end

      private

      def set_config
        @config = Workarea.config.email_theme
      end
    end
  end
end
