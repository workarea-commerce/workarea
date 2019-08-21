module Workarea
  module Admin
    class FulfillmentSkusController < Admin::ApplicationController
      required_permissions :catalog

      before_action :find_sku, except: :index
      after_action :track_index_filters, only: :index

      def index
        search = Search::AdminFulfillmentSkus.new(view_model_options)
        @search = SearchViewModel.new(search, view_model_options)
      end

      def show; end

      def create
        if @sku.save
          flash[:success] =
            t('workarea.admin.fulfillment_skus.flash_messages.created', id: @sku.id)
          redirect_to fulfillment_sku_path(@sku)
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit; end

      def update
        if @sku.update(params[:sku])
          flash[:success] = t('workarea.admin.fulfillment_skus.flash_messages.saved', id: @sku.id)
          redirect_to fulfillment_sku_path(@sku)
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @sku.destroy

        flash[:success] = t('workarea.admin.fulfillment_skus.flash_messages.removed', id: @sku.id)
        redirect_to fulfillment_skus_path
      end

      private

      def find_sku
        model =
          if params[:id].present?
            Fulfillment::Sku.find_or_create_by(id: params[:id])
          else
            Fulfillment::Sku.new(params[:sku])
          end

        @sku = FulfillmentSkuViewModel.new(model)
      end
    end
  end
end
