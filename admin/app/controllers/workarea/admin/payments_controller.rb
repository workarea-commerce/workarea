module Workarea
  module Admin
    class PaymentsController < Admin::ApplicationController
      required_permissions :orders

      def show
        @payment = PaymentViewModel.wrap(Payment.find(params[:id]))
        @order = OrderViewModel.wrap(Order.find(@payment.id))
      end
    end
  end
end
