module Workarea
  class Storefront::OrdersController < Storefront::ApplicationController
    def index
      redirect_to users_orders_path if logged_in?
    end

    def lookup
      @payment = Payment.lookup(params[:order_id], params[:postal_code])

      if @payment
        self.lookup_order = Order.find(@payment.id)
        redirect_to order_path(lookup_order)
      else
        self.lookup_order = nil
        flash[:error] = t('workarea.storefront.flash_messages.no_matching_order')
        redirect_to check_orders_path
      end
    end

    def show
      if lookup_order.try(:id).to_s.downcase != params[:id].to_s.downcase
        flash[:error] = t('workarea.storefront.flash_messages.no_matching_order')
        redirect_to check_orders_path
      end

      @order = Storefront::OrderViewModel.wrap(lookup_order, view_model_options)
    end
  end
end
