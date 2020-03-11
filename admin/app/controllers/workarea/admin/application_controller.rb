module Workarea
  module Admin
    class ApplicationController < Workarea::ApplicationController
      include Turbolinks::Controller
      include Authentication
      include Authorization
      include Impersonation
      include CurrentRelease
      include Visiting
      include Publishing

      layout :current_layout
      helper :all

      before_action { params.permit! }
      before_action :require_login
      before_action :require_admin
      before_action :check_authorization, except: :dashboard
      before_action :set_variant
      before_action :setup_alerts, if: :current_layout
      around_action :audit_log
      around_action :inline_search_indexing
      around_action :inline_cache_busting
      around_action :enable_auto_redirect

      def self.wrap_in_view_model(model, options = {})
        prefixes = [
          model.model_name.name.demodulize,
          model.model_name.param_key.camelize
        ]

        prefixes.each do |prefix|
          begin
            view_model_class_name = "Workarea::Admin::#{prefix}ViewModel"
            klass = view_model_class_name.constantize
            return klass.new(model, options)
          rescue NameError
            model
          end
        end

        model
      end

      def wrap_in_view_model(*args)
        self.class.wrap_in_view_model(*args)
      end

      def find_sort(klass)
        result = params[:sort].presence || klass.sorts.first.to_s

        klass.sorts.map do |sortable|
          if sortable.to_s == result
            return [sortable.field, sortable.direction]
          end
        end

        [:created_at, :desc]
      end

      def current_user
        if impersonating? || admin_browsing_as_guest?
          current_admin
        else
          super
        end
      end

      private

      def current_layout
        request.xhr? ? false : 'workarea/admin/application'
      end

      def set_variant
        request.variant ||= []
        request.variant << I18n.locale || I18n.default_locale
      end

      def audit_log
        Mongoid::AuditLog.record(current_user) do
          yield
        end
      end

      def inline_search_indexing
        Sidekiq::Callbacks.inline(IndexAdminSearch) { yield }
      end

      def inline_cache_busting
        Sidekiq::Callbacks.inline(BustNavigationCache, BustSkuCache) { yield }
      end

      def enable_auto_redirect
        Sidekiq::Callbacks.enable(RedirectNavigableSlugs) { yield }
      end

      def setup_alerts
        @alerts = AlertsViewModel.wrap(Alerts.new)
      end

      def track_index_filters
        session[:last_index_path] = request.fullpath unless request.xhr? || request.format.json?
      end
    end
  end
end
