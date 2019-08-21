module Workarea
  class ReleaseSession
    def initialize(cookies)
      @cookies = cookies
    end

    def remind?
      expired_by_time? || expired_by_page_views?
    end

    def expired_by_time?
      @cookies.permanent[:release_changed_at].present? &&
        Time.zone.parse(@cookies.permanent[:release_changed_at]) < timeout
    end

    def timeout
      Workarea.config.release_session_timeout.ago
    end

    def expired_by_page_views?
      @cookies.permanent[:release_page_views].present? &&
        @cookies.permanent[:release_page_views].to_i > max_page_views
    end

    def max_page_views
      Workarea.config.release_session_max_page_views
    end

    def save_page_view
      incremented = @cookies.permanent[:release_page_views].to_i + 1
      @cookies.permanent[:release_page_views] = incremented
    end

    def save_release_change
      reset!
      @cookies.permanent[:release_changed_at] = Time.current.to_s
    end
    alias_method :touch, :save_release_change

    def reset!
      @cookies.permanent[:release_page_views] = nil
      @cookies.permanent[:release_changed_at] = nil
    end
  end
end
