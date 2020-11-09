module Workarea
  module CurrentTracking
    extend ActiveSupport::Concern

    included do
      before_action :ensure_current_metrics
      helper_method :current_visit, :current_metrics

      delegate :current_metrics_id, :current_metrics_id=, :browser,
        to: :current_visit, allow_nil: true
    end

    def current_visit
      request.env['workarea.visit']
    end

    def current_metrics
      current_visit.metrics
    end

    def current_referrer
      current_visit.referrer
    end

    def update_tracking!(email: current_user&.email)
      if email.blank?
        cookies.delete(:email)
      elsif email != cookies.signed[:email]
        unless impersonating?
          Metrics::User
            .find_or_initialize_by(id: email)
            .merge_views!(current_visit&.metrics)
        end

        cookies.permanent.signed[:email] = email
      end

      request.env['workarea.visit'] = Visit.new(request.env)
    end

    # This method is mostly for tests, but could surface in an implementation.
    # Since Rails doesn't set and load a session until needed, an initial
    # request won't have a session ID for `current_visit` to check when loading
    # metrics. This ensures there will be one.
    def ensure_current_metrics
      return if current_metrics_id.present? || http_caching?

      # This forces Rails to initialize the session, which provides an ID for metrics
      session.delete(:foo)
      self.current_metrics_id = session.id.cookie_value
    end
  end
end
