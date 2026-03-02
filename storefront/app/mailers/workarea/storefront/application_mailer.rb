# frozen_string_literal: true
module Workarea
  module Storefront
    class ApplicationMailer < Workarea::ApplicationMailer
      layout 'workarea/storefront/email'
      helper_method :path_to_url
      before_action :set_config

      if respond_to?(:add_template_helper)
        add_template_helper ActionView::Helpers::AssetUrlHelper
        add_template_helper Workarea::DetailsHelper
        add_template_helper Workarea::Storefront::SchemaOrgHelper
      else
        helper ActionView::Helpers::AssetUrlHelper
        helper Workarea::DetailsHelper
        helper Workarea::Storefront::SchemaOrgHelper
      end

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
