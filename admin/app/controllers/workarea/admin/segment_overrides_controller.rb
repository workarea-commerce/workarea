module Workarea
  module Admin
    class SegmentOverridesController < Admin::ApplicationController
      def show
      end

      def create
        segment_ids = params[:segment_ids].to_h.select { |_, v| v =~ /true/ }.keys
        self.override_segments = Segment.in(id: segment_ids)

        if params[:return_to].present?
          redirect_to URI.parse(params[:return_to]).request_uri
        else
          redirect_back fallback_location: storefront.root_path
        end
      end
    end
  end
end
