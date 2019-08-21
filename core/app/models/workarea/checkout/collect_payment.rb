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
        Workarea.config.auto_capture ? 'purchase!' : 'authorize!'
      end
    end
  end
end
