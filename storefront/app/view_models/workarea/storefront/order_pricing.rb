module Workarea
  module Storefront
    module OrderPricing
      delegate :store_credit_balance, to: :payment

      def total_adjustments
        @total_adjustments ||= price_adjustments.reduce_by_description('order')
      end

      def store_credit?
        store_credit_amount > 0
      end

      def store_credit_amount
        if store_credit_balance > order.total_price
          order.total_price
        else
          store_credit_balance
        end
      end

      def order_balance
        order.total_price - advance_payment_amount
      end

      # The total amount of payment the customer would perceive as prepaid -
      # i.e. would be deducted from the total order balance. Examples of these
      # types of payments would be store credit and gift cards.
      #
      # @return [Money]
      #
      def advance_payment_amount
        store_credit_amount
      end
    end
  end
end
