module Workarea
  class Admin::DashboardsController < Admin::ApplicationController
    def index
      @dashboard = Admin::Dashboards::IndexViewModel.wrap(nil, view_model_options)
      @activity = Admin::ActivityViewModel.new(nil, view_model_options)
    end

    def store
      @dashboard = Admin::Dashboards::StoreViewModel.wrap(nil, view_model_options)
    end

    def search
      @dashboard = Admin::Dashboards::SearchViewModel.wrap(nil, view_model_options)
    end

    def catalog
      @dashboard = Admin::Dashboards::CatalogViewModel.wrap(nil, view_model_options)
    end

    def orders
      @dashboard = Admin::Dashboards::OrdersViewModel.wrap(nil, view_model_options)
    end

    def people
      @dashboard = Admin::Dashboards::PeopleViewModel.wrap(nil, view_model_options)
    end

    def marketing
      @dashboard = Admin::Dashboards::MarketingViewModel.wrap(nil, view_model_options)
    end

    def reports
      @dashboard = Admin::Dashboards::ReportsViewModel.wrap(nil, view_model_options)
    end

    def settings
      configuration = Workarea.config.merge(
        time_zone: Rails.application.config.time_zone
      )

      @settings = configuration.reject do |key, _value|
        Workarea.config.hide_from_settings.include?(key)
      end

      @configuration = Configuration::Admin.instance
    end

    # Override to provide permissions per-dashboard
    def required_permissions
      params[:action] unless params[:action] == 'index'
    end
  end
end
