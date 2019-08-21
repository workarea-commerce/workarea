module Workarea
  module Storefront
    class PaymentMailer < Storefront::ApplicationMailer
      include TransactionalMailer

      def refunded(refund_id)
        @refund = Payment::Refund.find(refund_id)

        model = Order.find(@refund.payment_id)
        @order = Storefront::OrderViewModel.wrap(model)
        @recommendations = Storefront::EmailRecommendationsViewModel.wrap(model)

        mail(
          to: @order.email,
          subject: t(
            'workarea.storefront.email.order_refund.subject',
            order_id: @order.id
          )
        )
      end
    end
  end
end
