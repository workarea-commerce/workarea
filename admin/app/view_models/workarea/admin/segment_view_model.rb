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

      def segmentables_count
        segmentables_search.total
      end

      def segmentables
        segmentables_search.results
      end

      def segmentables_search
        @segmentables_search ||= begin
          query = Search::AdminSearch.new(active_by_segment: [model.id])
          SearchViewModel.new(query, options)
        end
      end
    end
  end
end
