module Workarea
  module Admin
    class CatalogProductImagesController < Admin::ApplicationController
      required_permissions :catalog
      before_action :find_product

      def index
        @images = ProductImagesViewModel.new(@product)
      end

      def create
        @image = @product.images.build(params[:image])

        if @image.save
          flash[:success] = t('workarea.admin.catalog_product_images.flash_messages.created')
          redirect_to catalog_product_images_path(@product)
        else
          render :index, status: :unprocessable_entity
        end
      end

      def edit
        @image = @product.images.find(params[:id])
      end

      def update
        image = @product.images.find(params[:id])

        if image.update_attributes(params[:image])
          flash[:success] = t('workarea.admin.catalog_product_images.flash_messages.updated')
          redirect_to catalog_product_images_path(@product)
        else
          render :index, status: :unprocessable_entity
        end
      end

      def positions
        positions = params.fetch(:order, [])

        @product.images.each do |image|
          image.position = positions.index(image.id.to_s) || 999
        end

        @product.save!

        head :ok
      end

      def options
        @image_options ||= Catalog::Product.autocomplete_image_options(params[:q])
      end

      def destroy
        @product.images.find(params[:id]).destroy
        flash[:success] = t('workarea.admin.catalog_product_images.flash_messages.removed')
        redirect_to catalog_product_images_path(@product)
      end

      private

      def find_product
        model = Catalog::Product.find_by(slug: params[:catalog_product_id])
        @product = ProductViewModel.wrap(model, view_model_options)
      end
    end
  end
end
