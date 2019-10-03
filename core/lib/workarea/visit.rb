module Workarea
  class Visit
    class UnsupportedSessionAccess < RuntimeError; end

    attr_reader :env
    delegate :city, :region, :country, to: :geolocation

    def initialize(env)
      @env = env
    end

    def varies
      @varies ||= Cache::Varies.new(self)
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

    def request
      @request ||= ActionDispatch::Request.new(env)
    end

    def geolocation
      @geolocation ||= Workarea::Geolocation.new(env, request.remote_ip)
    end

    def current_email
      cookies.signed[:email]
    end

    def metrics
      return Metrics::User.new if current_metrics_id.blank?
      @metrics ||= Metrics::User.find_or_initialize_by(id: current_metrics_id)
    end

    # A value of 0 here means it's the first request we've seen
    def sessions
      @sessions ||= cookies[:sessions].to_i
    end

    def segments
      @segments ||= Segment.find_qualifying(self)
    end

    def referrer
      @referrer ||= Workarea.referrer_parser.parse(request.referrer)
    end

    def current_metrics_id
      @current_metrics_id || current_email.presence || session['session_id']
    end

    def current_metrics_id=(id)
      @current_metrics_id = id
      @metrics = nil
    end
  end
end
