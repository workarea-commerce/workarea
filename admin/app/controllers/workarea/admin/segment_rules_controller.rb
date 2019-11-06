module Workarea
  module Admin
    class SegmentRulesController < Admin::ApplicationController
      before_action :find_segment, except: :geolocation_options
      before_action :find_rules, except: :geolocation_options
      before_action :find_rule, except: [:index, :geolocation_options]

      def index
      end

      def geolocation_options
        @results = Segment::Rules::GeolocationOption.search(params[:q])
      end

      def create
        if @rule.save
          flash[:success] = t('workarea.admin.segment_rules.flash_messages.saved')
          redirect_to return_to || segment_rules_path(@segment)
        else
          flash[:error] = t('workarea.admin.segment_rules.flash_messages.error')
          render :index, status: :unprocessable_entity
        end
      end

      def update
        if @rule.update_attributes(params[:rule])
          flash[:success] = t('workarea.admin.segment_rules.flash_messages.saved')
          redirect_to return_to || segment_rules_path(@segment)
        else
          flash[:error] = t('workarea.admin.segment_rules.flash_messages.error')
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @rule.destroy
        flash[:success] = t('workarea.admin.segment_rules.flash_messages.destroyed')
        redirect_to return_to || segment_rules_path(@segment)
      end

      private

      def find_segment
        model = Segment.find(params[:segment_id])
        @segment = SegmentViewModel.wrap(model, view_model_options)
      end

      def find_rules
        @segment_rules = @segment.rules.select(&:persisted?)
      end

      def find_rule
        @rule = if params[:id].present?
          @segment.rules.where(id: params[:id]).first
        else
          klass = "Workarea::Segment::Rules::#{params[:rule_type].to_s.camelize}"
          @segment.model.rules.build(params[:rule], klass.constantize)
        end
      end
    end
  end
end
