module Workarea
  module Admin
    class RecommendationsController < Admin::ApplicationController
      required_permissions :catalog

      before_action :find_product
      before_action :find_settings

      def edit
      end

      def update
        @settings.sources = params[:sources].uniq if params[:sources].present?
        if @settings.update_attributes(params[:settings])
          flash[:success] = t('workarea.admin.recommendations.flash_messages.saved')
          redirect_to catalog_product_path(@product)
        else
          flash[:error] = t('workarea.admin.recommendations.flash_messages.changes_error')
          render :edit
        end
      end

      private

      def find_product
        model = Catalog::Product.find_by(slug: params[:catalog_product_id])
        @product = ProductViewModel.wrap(model, view_model_options)
      end

      def find_settings
        model = Recommendation::Settings.find_or_initialize_by(id: @product.id)
        @settings = RecommendationsViewModel.new(model, view_model_options)
      end
    end
  end
end
