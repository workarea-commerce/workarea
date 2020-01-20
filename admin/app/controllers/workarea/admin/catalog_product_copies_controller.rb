module Workarea
  module Admin
    class CatalogProductCopiesController < Admin::ApplicationController
      required_permissions :catalog
      before_action :find_source_product

      def new
      end

      def create
        @product_copy =
          CopyProduct.new(@product, params[:product].to_unsafe_h).perform

        if @product_copy.persisted?
          flash[:success] = t('workarea.admin.catalog_product_copies.flash_messages.created')
          redirect_to edit_create_catalog_product_path(@product_copy, continue: true)
        else
          flash[:error] = t('workarea.admin.catalog_product_copies.flash_messages.error')
          render :new
        end
      end

      private

      def find_source_product
        return unless params[:source_id].present?
        @product = Catalog::Product.find(params[:source_id])
      end
    end
  end
end
