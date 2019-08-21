module Workarea
  module Admin
    class ShippingsController < Admin::ApplicationController
      required_permissions :orders

      def index
        @order = OrderViewModel.wrap(
          Order.find(params[:order_id]),
          view_model_options
        )

        @shippings = ShippingViewModel.wrap(
          Shipping.by_order(params[:order_id]).to_a,
          view_model_options
        )
      end

      def show
        shipping = Shipping.find(params[:id])
        redirect_to order_shippings_path(Order.find(shipping.order_id))
      end
    end
  end
end
