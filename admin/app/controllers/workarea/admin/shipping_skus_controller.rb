module Workarea
  module Admin
    class ShippingSkusController < Admin::ApplicationController
      required_permissions :catalog

      after_action :track_index_filters, only: :index

      def index
        search = Search::AdminShippingSkus.new(view_model_options)
        @search = SearchViewModel.new(search, view_model_options)
      end

      def new
        @sku = ShippingSkuViewModel.wrap(Shipping::Sku.new)
      end

      def show
        @sku = ShippingSkuViewModel.wrap(
          Shipping::Sku.find_or_create_by(id: params[:id])
        )
      end

      def create
        @sku = Shipping::Sku.new(params[:sku])

        if @sku.save
          flash[:success] =
            t('workarea.admin.shipping_skus.saved', sku: @sku.id)
          redirect_to shipping_sku_path(@sku)
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        @sku = ShippingSkuViewModel.wrap(Shipping::Sku.find(params[:id]))
      end

      def update
        @sku = Shipping::Sku.find(params[:id])

        if @sku.update_attributes(params[:sku])
          flash[:success] =
            t('workarea.admin.shipping_skus.saved', sku: @sku.id)
          redirect_to shipping_sku_path(@sku)
        else
          @sku = ShippingSkuViewModel.new(@sku)
          render :edit, status: :unprocessable_entity
        end
      end
    end
  end
end
