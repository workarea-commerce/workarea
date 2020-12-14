module Workarea
  module Storefront
    module Checkout
      class AddressesController < CheckoutsController
        after_action :validate_shipping_options, only: :update_addresses

        # GET /checkout/addresses
        def addresses
          @step ||= Storefront::Checkout::AddressesViewModel.new(
            addresses_step,
            view_model_options
          )
        end

        # PATCH /checkout/addresses
        def update_addresses
          if invalid_recaptcha?(action: 'checkout/addresses')
            challenge_recaptcha!
            incomplete_addresses_step
          else
            addresses_step.update(params)

            if addresses_step.complete?
              completed_addresses_step
            else
              incomplete_addresses_step
            end
          end
        end

        private

        def addresses_step
          @addresses_step ||= Workarea::Checkout::Steps::Addresses.new(current_checkout)
        end

        def completed_addresses_step
          flash[:success] = t('workarea.storefront.flash_messages.addresses_saved')

          if current_order.requires_shipping?
            redirect_to checkout_shipping_path
          else
            Workarea::Checkout::Steps::Shipping.new(current_checkout).update
            redirect_to checkout_payment_path
          end
        end

        def incomplete_addresses_step
          addresses
          render :addresses
        end

        def validate_shipping_options
          return unless current_order.requires_shipping?

          available_options = Workarea::Storefront::CartViewModel.new(current_order).shipping_options

          if available_options.empty?
            flash[:error] = t('workarea.storefront.flash_messages.no_available_shipping_options')
          end
        end
      end
    end
  end
end
