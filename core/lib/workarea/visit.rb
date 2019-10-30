module Workarea
  class Visit
    class UnsupportedSessionAccess < RuntimeError; end

    attr_reader :env
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
      cookies.signed[:email]
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
      @segments ||= Segment.find_qualifying(self)
    end

    def referrer
      return @referrer if defined?(@referrer)
      @referrer = Workarea.referrer_parser.parse(request.referrer) rescue {}
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
  end
end
