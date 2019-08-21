module Workarea
  module Storefront
    class ApplicationMailer < Workarea::ApplicationMailer
      layout 'workarea/storefront/email'
      helper_method :path_to_url
      before_action :set_config

      add_template_helper ActionView::Helpers::AssetUrlHelper
      add_template_helper Workarea::DetailsHelper
      add_template_helper Workarea::Storefront::SchemaOrgHelper

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
