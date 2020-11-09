module Workarea
  module Storefront
    class CartItemsController < Storefront::ApplicationController
      include CheckInventory
      include CheckPricingOverride

      skip_before_action :verify_authenticity_token, only: [:create]
      before_action :check_pricing_override, only: [:create, :update, :destroy]
      before_action :validate_customizations, only: [:create, :update]
      before_action :product, only: :create
      after_action :check_inventory, except: :create

      def create
        @cart = CartViewModel.new(current_order, view_model_options)

        # TODO: for v4, use AddItemToCart for this.
        if current_order.add_item(item_params.to_h.merge(item_details.to_h))
          check_inventory

          Pricing.perform(current_order, current_shippings)

          @item = OrderItemViewModel.wrap(
            current_order.items.find_existing(
              item_params[:sku],
              item_params.to_h
            ),
            view_model_options
          )
        end
      end

      def update
        update_params = params.permit(:sku, :quantity).to_h
        update_params.merge!(item_details.to_h) if params[:sku].present?

        current_order.update_item(params[:id], update_params)
        flash[:success] = t('workarea.storefront.flash_messages.cart_item_updated')
        redirect_to cart_path
      end

      def destroy
        current_order.remove_item(params[:id])
        flash[:success] = t('workarea.storefront.flash_messages.cart_item_removed')
        redirect_to cart_path
      end

      private

      def product
        @product = ProductViewModel.wrap(
          Workarea::Catalog::Product.find_by_sku(params[:sku]),
          view_model_options
        )
      end

      def item_params
        @item_params ||= params
                           .permit(:product_id, :sku, :quantity, :via)
                           .merge(customizations: customization_params)
      end

      def product_id
        @product_id ||= if params[:product_id].present?
                          params[:product_id]
                        elsif params[:sku].present?
                          Catalog::Product.find_by_sku(params[:sku]).id
                        elsif params[:id].present?
                          current_order.items.find(params[:id]).product_id
                        end
      end

      def item_details
        ActionController::Parameters.new(
          OrderItemDetails.find!(params[:sku], product_id: product_id).to_h
        ).permit!
      end

      def customizations
        @customizations ||= Catalog::Customizations.find(
          product_id,
          params.to_unsafe_h
        )
      end

      def customization_params
        ActionController::Parameters.new(
          customizations.try(:to_h) || {}
        ).permit!
      end

      def validate_customizations
        if customizations.present? && !customizations.valid?
          flash[:error] = customizations.errors.full_messages.join(', ')
          redirect_back(fallback_location: product_path(Catalog::Product.find(product_id)))
          return false
        end
      end
    end
  end
end
