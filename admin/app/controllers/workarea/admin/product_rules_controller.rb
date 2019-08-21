module Workarea
  module Admin
    class ProductRulesController < Admin::ApplicationController
      before_action :find_product_list
      before_action :find_product_rules
      before_action :find_product_rule, except: :index
      before_action :set_preview
      before_action :validate_query_syntax, only: [:create, :update, :preview]

      def index; end

      def new
        render :index
      end

      def create
        if @product_rule.errors.none? && @product_rule.save
          flash[:success] = t('workarea.admin.product_rules.flash_messages.saved')
          redirect_to return_to || product_list_product_rules_path(
            @product_list.to_global_id
          )
        else
          @product_list.reload

          flash[:error] = t(
            'workarea.admin.product_rules.flash_messages.error',
            errors: @product_rule.errors.full_messages.to_sentence
          )
          render :index, status: :unprocessable_entity
        end
      end

      def preview
      end

      def edit
        render :index
      end

      def update
        if @product_rule.errors.none? && @product_rule.save
          flash[:success] = t('workarea.admin.product_rules.flash_messages.saved')
          redirect_back_or product_list_product_rules_path(@product_list.to_global_id)
        else
          @product_list.reload

          flash[:error] = t(
            'workarea.admin.product_rules.flash_messages.error',
            errors: @product_rule.errors.full_messages.to_sentence
          )
          render :index, status: :unprocessable_entity
        end
      end

      def destroy
        @product_rule.destroy
        flash[:success] = t('workarea.admin.product_rules.flash_messages.destroyed')
        redirect_back_or product_list_product_rules_path(@product_list.to_global_id)
      end

      private

      def find_product_list
        model = GlobalID::Locator.locate(params[:product_list_id])
        @product_list = wrap_in_view_model(model, view_model_options)
        @preview = ProductRulesPreviewViewModel.wrap(model, view_model_options)
      end

      def find_product_rules
        @product_rules = @product_list.product_rules.usable.select(&:persisted?)
      end

      def find_product_rule
        @product_rule = @product_list.product_rules.find(params[:id])
      rescue Mongoid::Errors::DocumentNotFound, Mongoid::Errors::InvalidFind
        @product_rule = @product_list.model.product_rules.build
      ensure
        @product_rule.assign_attributes(params[:product_rule])
      end

      def set_preview
        @preview = ProductRulesPreviewViewModel.wrap(
          @product_list.model,
          view_model_options
        )
      end

      def validate_query_syntax
        return unless @product_rule.name == 'search'
        Search::CategoryBrowse.new(rules: [@product_rule]).results
      rescue ::Elasticsearch::Transport::Transport::ServerError
        @product_rule.errors.add(:base, t('workarea.admin.product_rules.invalid_lucene_syntax'))
      end
    end
  end
end
