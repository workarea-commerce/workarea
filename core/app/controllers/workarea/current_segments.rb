module Workarea
  module CurrentSegments
    extend ActiveSupport::Concern
    include CurrentTracking

    included do
      helper_method :current_segments, :override_segments
      after_action :mark_segmented_content
    end

    def self.segmented_content?
      !!Thread.current[:segmented_content]
    end

    def self.has_segmented_content!
      Thread.current[:segmented_content] = true
    end

    def self.reset_segmented_content
      Thread.current[:segmented_content] = nil
    end

    def override_segments
      return [] if session[:segment_ids].blank?
      @override_segments ||= Segment.in(id: session[:segment_ids]).to_a
    end

    def override_segments=(segments)
      if segments.blank?
        session.delete(:segment_ids)
        return
      end

      session[:segment_ids] = segments.map(&:id)
    end

    def current_segments
      Segment.current
    end

    def apply_segments
      segments = logged_in? && current_user.admin? ? override_segments : current_visit&.segments
      Segment.with_current(segments) { yield }
    end

    def mark_segmented_content
      if CurrentSegments.segmented_content?
        response.set_header('X-Workarea-Segmented-Content', 'true')
      end

    ensure
      CurrentSegments.reset_segmented_content
    end
  end
end
