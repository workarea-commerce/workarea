module Workarea
  class Visit
    class UnsupportedSessionAccess < RuntimeError; end

    attr_reader :env
    attr_writer :override_segments

    delegate :postal_code, :city, :subdivision, :region, :country, to: :geolocation

    def initialize(env)
      @env = env
    end

    def cookies
      request.cookie_jar
    end

    def session
      raise UnsupportedSessionAccess unless Configuration::Session.cookie_store?
      @session ||= (cookies.signed_or_encrypted[Configuration::Session.key] || {}).with_indifferent_access
    end

    def logged_in?
      session[:user_id].present?
    end

    def impersonating?
      session[:admin_id].present?
    end

    def admin?
      (logged_in? && impersonating?) || metrics.admin?
    end

    def request
      @request ||= ActionDispatch::Request.new(env)
    end

    def geolocation
      @geolocation ||= Workarea::Geolocation.new(env, request.remote_ip)
    end

    def location_names
      geolocation.names
    end

    def current_email
      # For performance, prefer to use the cookie. The fallback to looking it up
      # by user is a failsafe against a blank email cookie (e.g. from a raised
      # error or poor application coding).
      cookies.signed[:email].presence || (email_from_user_id if logged_in?)
    end

    def metrics
      return blank_metrics if current_metrics_id.blank?
      @metrics ||= Metrics::User.find_or_initialize_by(id: current_metrics_id)
    end

    # A value of 0 here means it's the first request we've seen
    def sessions
      @sessions ||= cookies[:sessions].to_i
    end

    def segments
      @segments ||= Workarea::Segment.find_qualifying(self)
    end

    def override_segments
      @override_segments ||= Workarea::Segment.in(id: session[:segment_ids]).to_a
    end

    def applied_segments
      admin? ? override_segments : segments
    end

    def referrer
      @referrer ||= begin
        value = cookies['workarea_referrer'].presence || request.referrer
        attributes = Workarea.referrer_parser.parse(value) rescue {}
        TrafficReferrer.new(attributes)
      end
    end

    def browser
      @browser ||= Browser.new(env['HTTP_USER_AGENT'], accept_language: env['HTTP_ACCEPT_LANGUAGE'])
    end

    def current_metrics_id
      return @current_metrics_id if defined?(@current_metrics_id)
      @current_metrics_id = current_email.presence || session['session_id']
    end

    def current_metrics_id=(id)
      @current_metrics_id = id
      @metrics = nil
    end

    private

    # Memoizing this saves a lot of allocated objects
    def blank_metrics
      @blank_metrics ||= Metrics::User.new
    end

    def email_from_user_id
      User.find(session[:user_id]).email rescue nil
    end
  end
end
