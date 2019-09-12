module Workarea
  module Admin
    class SegmentsController < Admin::ApplicationController
      required_permissions :people

      before_action :find_segment, except: :index

      def index
        query = Search::AdminSegments.new(params)
        @search = SearchViewModel.new(query, view_model_options)
        @segments = SegmentViewModel.wrap(Segment.all, view_model_options)
      end

      def show
      end

      def edit
      end

      def update
        if @segment.update_attributes(params[:segment])
          flash[:success] = t('workarea.admin.segments.flash_messages.saved')
          redirect_to segment_path(@segment)
        else
          flash[:error] = @segment.errors.full_messages.to_sentence
          render :edit, status: :unprocessable_entity
        end
      end

      def insights
      end

      def destroy
        head :unprocessable_entity && return if @segment.life_cycle?

        @segment.destroy
        flash[:success] = t('workarea.admin.segments.flash_messages.removed')
        redirect_to segments_path
      end

      private

      def find_segment
        @segment = Admin::SegmentViewModel.new(Segment.find(params[:id]))
      end
    end
  end
end
