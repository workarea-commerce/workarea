# frozen_string_literal: true

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

      # Security note — params.permit! (MassAssignment / Brakeman CWE-915)
      #
      # `params.permit!` marks all params as permitted so that sub-hashes can be
      # passed directly to Mongoid models without triggering
      # ActionController::UnpermittedParameters. This is an intentional,
      # deliberate decision for the following reasons:
      #
      # 1. **Admin-only, fully authenticated surface.**  Every request that
      #    reaches any controller inheriting from this class has already passed:
      #      - `require_login`      — valid Rails session for a known User
      #      - `require_admin`      — user.admin? must be true
      #      - `check_authorization`— per-resource permission check via
      #                               Workarea::Authorization
      #    Unauthenticated or non-admin requests are rejected before any
      #    controller action (or model write) is ever reached.
      #
      # 2. **Highly polymorphic admin data model.**  The admin manages Mongoid
      #    documents whose schemas are open-ended:
      #      - Catalog products/variants carry user-defined `details` and
      #        `filters` hashes whose keys vary per merchant configuration.
      #      - Content blocks use plugin-defined field schemas registered at
      #        boot time (see Workarea.config.content_block_types).
      #      - Plugin gems add fields to any model via Mongoid mixins without
      #        touching this gem.
      #    A static `permit(:field_a, :field_b, ...)` list cannot cover these
      #    dynamic structures and would silently strip legitimate admin input.
      #
      # 3. **Threat model alignment.**  Rails strong parameters protect public
      #    surfaces (storefront, API) from untrusted users assigning arbitrary
      #    attributes.  The admin is operated by trusted staff with explicit
      #    CRUD permissions granted by a super-admin — the risk profile is
      #    equivalent to a privileged Rails console session, not a public API.
      #
      # 4. **Backward compatibility.**  This gem is open-source with many
      #    downstream host apps.  Introducing a restricted permit list here
      #    would be a breaking change for any plugin or app that passes custom
      #    parameters through the admin.
      #
      # The two Brakeman MassAssignment fingerprints for this line are tracked
      # in admin/brakeman.baseline.json so that CI (--compare) fails only on
      # *new* mass-assignment introductions, not this known-accepted pattern.
      #
      # Reviewed: 2026-03 — WA-SEC-017
      before_action { params.permit! } # rubocop:disable Rails/StrongParameters
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
