module Workarea
  class Order
    module Status
      class Cart
        include StatusCalculator::Status

        def in_status?
          !order.canceled? &&
            !order.placed? &&
            !order.checking_out? &&
            !order.abandoned? &&
            !order.fraud_suspected?
        end
      end

      class Canceled
        include StatusCalculator::Status

        def in_status?
          order.canceled?
        end
      end

      class Placed
        include StatusCalculator::Status

        def in_status?
          order.placed?
        end
      end

      class Checkout
        include StatusCalculator::Status

        def in_status?
          order.checking_out?
        end
      end

      class Abandoned
        include StatusCalculator::Status

        def in_status?
          order.abandoned?
        end
      end

      class SuspectedFraud
        include StatusCalculator::Status

        def in_status?
          order.fraud_suspected?
        end
      end
    end
  end
end
