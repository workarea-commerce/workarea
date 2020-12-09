module Workarea
  module Storefront
    module Checkout
      class ShippingController < CheckoutsController
        # GET /checkout/shipping
        def shipping
          @step ||= Storefront::Checkout::ShippingViewModel.new(
            shipping_step,
            view_model_options
          )
        end

        # PATCH /checkout/payment
        def update_shipping
          if invalid_recaptcha?(action: 'checkout/shipping')
            challenge_recaptcha!
            incomplete_place_order
          else
            shipping_step.update(params)

            if request.xhr?
              updated_shipping_step_summary
            elsif shipping_step.complete?
              completed_shipping_step
            else
              incomplete_shipping_step
            end
          end
        end

        private

        def shipping_step
          @shipping_step ||= Workarea::Checkout::Steps::Shipping.new(current_checkout)
        end

        def updated_shipping_step_summary
          Pricing.perform(current_order, current_shippings)

          shipping
          render :summary
        end

        def completed_shipping_step
          flash[:success] = t('workarea.storefront.flash_messages.shipping_options_saved')
          redirect_to checkout_payment_path
        end

        def incomplete_shipping_step
          Pricing.perform(current_order, current_shippings)

          shipping
          render :shipping
        end
      end
    end
  end
end
