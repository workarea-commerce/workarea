module Workarea
  module Admin
    class PricesController < Admin::ApplicationController
      required_permissions :catalog

      before_action :check_publishing_authorization
      before_action :find_sku
      before_action :find_price, except: [:index, :new]

      def index
      end

      def new
      end

      def create
        if @price.save
          flash[:success] =
            t('workarea.admin.prices.flash_messages.saved', sku: @sku.id)
          redirect_to pricing_sku_prices_path(@sku)
        else
          render :index, status: :unprocessable_entity
        end
      end

      def edit
      end

      def update
        if @price.update_attributes(price_params)
          flash[:success] =
            t('workarea.admin.prices.flash_messages.saved', sku: @sku.id)
          redirect_to pricing_sku_prices_path(@sku)
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @price.destroy

        flash[:success] =
          t('workarea.admin.prices.flash_messages.deleted', sku: @sku.id)
        redirect_to pricing_sku_prices_path(@sku)
      end

      private

      def price_params
        # Blank strings convert to $0 when to_money is called
        (params[:price] || {}).transform_values(&:presence)
      end

      def find_sku
        @sku = PricingSkuViewModel.wrap(
          Pricing::Sku.find(params[:pricing_sku_id])
        )
      end

      def find_price
        @price = if params[:id].present?
                   @sku.prices.find_or_create_by(id: params[:id])
                 else
                   @sku.prices.build(price_params)
                 end
      end
    end
  end
end
