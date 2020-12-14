module Workarea
  module Storefront
    module Checkout
      class PlaceOrderController < PaymentController
        # PATCH /checkout/place_order
        def place_order
          if invalid_recaptcha?(action: 'checkout/place_order')
            challenge_recaptcha!
            incomplete_place_order
          else
            payment_step.update(params)

            if payment_step.complete?
              try_place_order
            else
              incomplete_place_order
            end
          end
        end

        # GET /checkout/confirmation
        def confirmation
          redirect_to cart_path and return unless completed_order.present?

          @content = Storefront::Checkout::ConfirmationViewModel.new
          @order = Storefront::OrderViewModel.new(completed_order)
        end

        private

        def try_place_order
          if current_checkout.place_order
            completed_place_order
          else
            incomplete_place_order
          end
        end

        def completed_place_order
          OrderMailer.confirmation(current_order.id).deliver_later
          self.completed_order = current_order
          clear_current_order

          flash[:success] = t('workarea.storefront.flash_messages.order_placed')
          redirect_to finished_checkout_destination
        end

        def incomplete_place_order
          if current_checkout.shipping.try(:errors).present?
            flash[:error] = current_checkout.shipping.errors.to_a.to_sentence
            redirect_to checkout_shipping_path
          else
            flash[:error] = t('workarea.storefront.flash_messages.order_place_error')

            payment
            render :payment
          end
        end

        def finished_checkout_destination
          if current_admin.present? && current_admin.orders_access?
            admin.order_path(completed_order)
          else
            checkout_confirmation_path
          end
        end
      end
    end
  end
end
