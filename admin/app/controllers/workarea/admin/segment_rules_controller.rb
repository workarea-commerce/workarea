# frozen_string_literal: true

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
        if @rule.update(params[:rule])
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
          klass = segment_rule_class_for(params[:rule_type])
          head(:unprocessable_entity) and return unless klass
          @segment.model.rules.build(params[:rule], klass)
        end
      end

      def segment_rule_class_for(rule_type)
        slug = rule_type.to_s.underscore
        Workarea.config.segment_rule_types.lazy
          .map { |t| t.constantize }
          .find { |klass| klass.slug.to_s == slug }
      end
    end
  end
end
