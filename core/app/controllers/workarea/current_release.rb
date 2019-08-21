module Workarea
  module CurrentRelease
    extend ActiveSupport::Concern

    included do
      helper_method :current_release, :current_release_session
      around_action :set_release
      before_action :mark_release_session
    end

    private

    def set_release
      if current_release_id.blank? || !current_user.try(:admin?)
        Release.current = nil
        yield
      else
        Release.with_current(current_release_id) do
          yield
        end
      end
    end

    def mark_release_session
      return unless current_user.try(:admin?)

      if working_with_releases? || current_release.blank?
        current_release_session.reset!
      elsif request.get? && !request.xhr?
        current_release_session.save_page_view
      end
    end

    def working_with_releases?
      request.url =~ /release/ || request.referer =~ /release/
    end

    def current_release_id
      session[:release_id]
    end

    def current_release
      Release.current
    end

    def current_release=(release)
      current_release_session.save_release_change if release.present?
      session[:release_id] = release.try(:id)
      Release.current = release
    end

    def current_release_session
      @current_release_session ||= ReleaseSession.new(session)
    end
  end
end
