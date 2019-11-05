module Workarea
  module Admin
    class SegmentablesController < Admin::ApplicationController
      required_permissions :people

      def index
        @segment = Admin::SegmentViewModel.new(Segment.find(params[:segment_id]))
        @search = @segment.segmentables_search
      end
    end
  end
end
