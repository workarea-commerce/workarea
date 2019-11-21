module Workarea
  class Checkout
    class CollectPayment
      delegate :payment, to: :@checkout

      def initialize(checkout)
        @checkout = checkout
        @order = checkout.order
      end

      def valid?
        if balance > 0
          payment.errors.add(
            :base,
            I18n.t('workarea.payment.insufficient_payment', balance: balance)
          )

          return false
        end

        true
      end

      def balance
        @order.total_price - payment.tendered_amount
      end

      def purchase
        return true if @order.total_price.zero?
        return false unless valid?

        payment.send(action, checkout: @checkout)
      end

      def action
        # TODO deprecated, remove in v3.6
        return 'purchase!' if Workarea.config.auto_capture

        if @order.items.all?(&:shipping?)
          Workarea.config.checkout_payment_action[:shipping]
        elsif @order.items.any?(&:shipping?)
          Workarea.config.checkout_payment_action[:partial_shipping]
        else
          Workarea.config.checkout_payment_action[:no_shipping]
        end
      end
    end
  end
end
