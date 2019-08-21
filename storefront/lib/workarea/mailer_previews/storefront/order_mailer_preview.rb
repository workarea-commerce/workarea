module Workarea
  module Storefront
    class OrderMailerPreview < ActionMailer::Preview

      def order_confirmation
        order = OrderViewModel.new(Order.placed.last)
        OrderMailer.confirmation(order.id)
      end

      def reminder
        order = Order.where(:email.exists => true).first
        OrderMailer.reminder(order.id)
      end
    end
  end
end
