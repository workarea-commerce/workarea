module Workarea
  class ReleaseSession
    def initialize(session)
      @session = session
    end

    def remind?
      expired_by_time? || expired_by_page_views?
    end

    def expired_by_time?
      @session[:release_changed_at].present? &&
        Time.zone.parse(@session[:release_changed_at]) < timeout
    end

    def timeout
      Workarea.config.release_session_timeout.ago
    end

    def expired_by_page_views?
      @session[:release_page_views].present? &&
        @session[:release_page_views].to_i > max_page_views
    end

    def max_page_views
      Workarea.config.release_session_max_page_views
    end

    def save_page_view
      incremented = @session[:release_page_views].to_i + 1
      @session[:release_page_views] = incremented
    end

    def save_release_change
      reset!
      @session[:release_changed_at] = Time.current.to_s
    end
    alias_method :touch, :save_release_change

    def reset!
      @session.delete(:release_page_views)
      @session.delete(:release_changed_at)
    end
  end
end
