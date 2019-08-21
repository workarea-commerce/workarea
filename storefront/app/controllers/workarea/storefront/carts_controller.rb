module Workarea
  module Storefront
    class CartsController < Storefront::ApplicationController
      include CheckInventory
      include CheckPricingOverride

      before_action :remove_unpurchasable_items
      before_action :check_pricing_override, only: :add_promo_code
      after_action :check_inventory, except: :show

      def show
        Pricing.perform(current_order, current_shippings)
        @cart = CartViewModel.new(current_order, view_model_options)
      end

      def add_promo_code
        if Pricing.valid_promo_code?(params[:promo_code], current_checkout.email)
          current_order.add_promo_code(params[:promo_code])
          flash[:success] = t(
            'workarea.storefront.flash_messages.promo_code_added',
            promo_code: params[:promo_code]
          )

          redirect_to promo_code_destination
        else
          flash[:error] = t('workarea.storefront.flash_messages.promo_code_error')
          redirect_to "#{promo_code_destination}?#{params[:promo_code].to_query(:promo_code)}"
        end
      end

      def resume
        if order = Order.find_by(token: params[:token]) rescue nil
          self.current_order = order
          flash[:success] = t('workarea.storefront.flash_messages.order_resumed')
        else
          flash[:error] = t('workarea.storefront.flash_messages.order_not_resumed')
        end

        redirect_to cart_path
      end

      private

      def remove_unpurchasable_items
        cleaner = CartCleaner.new(current_order)
        cleaner.clean
        flash[:info] = cleaner.messages if cleaner.message?
      end

      def promo_code_destination
        uri = URI.parse(
          params[:return_to].presence ||
          request.referer.presence ||
          cart_path
        )

        uri.path
      end
    end
  end
end
