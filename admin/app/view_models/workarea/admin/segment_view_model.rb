module Workarea
  module Admin
    class SegmentViewModel < ApplicationViewModel
      include CommentableViewModel

      def timeline
        @timeline ||= TimelineViewModel.new(model)
      end

      def life_cycle?
        model.is_a?(Segment::LifeCycle)
      end

      def insights
        @insights ||= Insights::SegmentViewModel.wrap(model, options)
      end
    end
  end
end
