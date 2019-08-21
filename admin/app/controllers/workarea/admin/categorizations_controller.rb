module Workarea
  module Admin
    class CategorizationsController < Admin::ApplicationController
      required_permissions :catalog

      before_action :check_publishing_authorization
      before_action :find_product

      def index
      end

      def create
        Catalog::Category.in(id: params[:category_ids]).each do |category|
          category.add_product(@product.id)
        end

        flash[:success] = t('workarea.admin.categorizations.flash_messages.added')
        redirect_to catalog_product_categorizations_path(@product)
      end

      def destroy
        category = Catalog::Category.find_by(slug: params[:id])
        category.remove_product(@product.id)

        flash[:success] = t('workarea.admin.categorizations.flash_messages.removed')
        head :ok
      end

      private

      def find_product
        model = Catalog::Product.find_by(slug: params[:catalog_product_id])
        @product = ProductViewModel.new(model, view_model_options)
      end
    end
  end
end
