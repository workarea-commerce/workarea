module Workarea
  module Admin
    class CreateSegmentsController < Admin::ApplicationController
      required_permissions :people

      before_action :find_segment
      before_action :find_rules, only: [:rules, :new_rule, :edit_rule]
      before_action :find_rule, only: [:new_rule, :edit_rule]

      def index
        render :setup
      end

      def create
        @segment.attributes = params[:segment]

        if @segment.save
          flash[:success] = t('workarea.admin.create_segments.flash_messages.saved')
          redirect_to rules_create_segment_path(@segment)
        else
          render :setup, status: :unprocessable_entity
        end
      end

      def edit
        render :setup
      end

      def rules
      end

      def new_rule
        render :rules
      end

      def edit_rule
        render :rules
      end

      def review
      end

      private

      def find_segment
        model = if params[:id].present?
                  Segment.find(params[:id])
                else
                  Segment.new(params[:segment])
                end

        @segment = SegmentViewModel.wrap(model, view_model_options)
      end

      def find_rules
        @rules = @segment.rules.select(&:persisted?)
      end

      def find_rule
        @rule = if params[:rule_id].present?
          @segment.rules.where(id: params[:rule_id]).first
        else
          klass = "Workarea::Segment::Rules::#{params[:rule_type].to_s.camelize}"
          @segment.model.rules.build(params[:rule], klass.constantize)
        end
      end
    end
  end
end
