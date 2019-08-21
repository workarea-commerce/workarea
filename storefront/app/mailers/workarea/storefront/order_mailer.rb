module Workarea
  module Storefront
    class OrderMailer < Storefront::ApplicationMailer
      include TransactionalMailer

      def confirmation(order_id)
        order = Order.find(order_id)
        @order = Storefront::OrderViewModel.new(order)
        @content = Content::Email.find_content('order_confirmation')
        @recommendations = Storefront::EmailRecommendationsViewModel.wrap(order)

        mail(
          to: @order.email,
          subject: t('workarea.storefront.email.order_confirmation.subject', order_id: @order.id)
        )
      end

      def reminder(order_id)
        order = Order.find(order_id)
        @order = Storefront::OrderViewModel.new(order)
        @content = Content::Email.find_content('order_reminder')
        @recommendations = Storefront::EmailRecommendationsViewModel.wrap(order)

        mail(
          to: order.email,
          subject: t('workarea.storefront.email.order_reminder.subject')
        )
      end
    end
  end
end
