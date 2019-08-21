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

        if @order.items.all?(&:requires_shipping?)
          Workarea.config.checkout_payment_action[:shipped]
        elsif @order.items.any?(&:requires_shipping?)
          Workarea.config.checkout_payment_action[:mixed]
        else
          Workarea.config.checkout_payment_action[:not_shipped]
        end
      end
    end
  end
end
