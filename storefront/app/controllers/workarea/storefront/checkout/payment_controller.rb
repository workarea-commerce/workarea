module Workarea
  module Storefront
    module Checkout
      class PaymentController < CheckoutsController
        # GET /checkout/payment
        def payment
          @step = Storefront::Checkout::PaymentViewModel.new(
            payment_step,
            view_model_options
          )
        end

        private

        def payment_step
          @payment_step ||= Workarea::Checkout::Steps::Payment.new(current_checkout)
        end
      end
    end
  end
end
