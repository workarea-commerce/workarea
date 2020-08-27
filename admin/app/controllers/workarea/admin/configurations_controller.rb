module Workarea
  module Admin
    class ConfigurationsController < Admin::ApplicationController
      required_permissions :settings

      before_action :find_configuration

      def show; end

      def update
        if @configuration.update(configuration_params)
          flash[:success] = t('workarea.admin.configurations.flash_messages.configuration_updated')
          redirect_to configuration_path
        else
          flash[:error] = t('workarea.admin.configurations.flash_messages.configuration_error')
          render :show
        end
      end

      private

      def find_configuration
        @configuration = Configuration::Admin.instance
      end

      def configuration_params
        Configuration::Params.new(params[:configuration].to_unsafe_h).to_h
      end
    end
  end
end
