module Workarea
  module Admin
    class InventorySkusController < Admin::ApplicationController
      required_permissions :catalog

      before_action :find_sku, except: :index
      after_action :track_index_filters, only: :index

      def index
        search_params = if product
                          view_model_options.merge(q: product.skus.join(' '))
                        else
                          view_model_options
                        end

        search = Search::AdminInventorySkus.new(search_params)
        @search = SearchViewModel.new(search, search_params)
      end

      def show
        @sku = InventorySkuViewModel.new(@sku)
      end

      def create
        if @sku.save
          flash[:success] =
            t('workarea.admin.inventory_skus.flash_messages.created', id: @sku.id)
          redirect_to inventory_sku_path(@sku)
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        @sku = InventorySkuViewModel.new(@sku)
      end

      def update
        if @sku.update_attributes(params[:sku])
          flash[:success] =
            t('workarea.admin.inventory_skus.flash_messages.saved', id: @sku.id)
          redirect_to inventory_sku_path(@sku)
        else
          @sku = InventorySkuViewModel.new(@sku)
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @sku.destroy
        flash[:success] =
          t('workarea.admin.inventory_skus.flash_messages.removed', id: @sku.id)
        redirect_to inventory_skus_path
      end

      private

      def matching_sku
        if params[:q].present?
          @matching_sku ||= Inventory::Sku.where(id: params[:q]).first
        end
      end

      def product
        if params[:product_id].present?
          Catalog::Product.find(params[:product_id])
        end
      end

      def find_sku
        @sku = if params[:id].present?
          Inventory::Sku.find_or_create_by(id: params[:id])
        else
          Inventory::Sku.new(params[:sku])
        end
      end
    end
  end
end
