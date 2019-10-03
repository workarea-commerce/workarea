module Workarea
  module CurrentSegments
    extend ActiveSupport::Concern
    include CurrentTracking

    included do
      helper_method :current_segments, :override_segments
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
      segments = logged_in? && current_user.admin? ? override_segments : current_visit.segments
      Segment.with_current(segments) { yield }
    end
  end
end
