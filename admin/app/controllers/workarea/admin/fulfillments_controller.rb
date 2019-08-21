module Workarea
  module Admin
    class FulfillmentsController < Admin::ApplicationController
      required_permissions :orders

      def show
        @fulfillment = FulfillmentViewModel.wrap(
          Fulfillment.find_or_initialize_by(id: params[:id])
        )

        @order = OrderViewModel.wrap(Order.find(params[:id]))
      end
    end
  end
end
