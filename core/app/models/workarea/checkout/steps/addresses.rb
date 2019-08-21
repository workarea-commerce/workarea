module Workarea
  class Checkout
    module Steps
      class Addresses < Base

        # The default shipping option that will be assigned to this checkout
        # when updating. Retrieved from {Checkout::ShippingOptions}
        #
        # @return [Shipping::Option]
        #
        def default_shipping_option
          shipping_options.first
        end

        # Update the addresses step of checkout. Includes:
        # * email address (from params or user)
        # * shipping address (if shippable)
        # * shipping service (assigning a default if none exists and shippable)
        # * billing address
        #
        # @param [Hash] params
        # @option params [String] :email The email for the order
        # @option params [Hash] :shipping_address Shipping address attributes (not set if blank)
        # @option params [Hash] :billing_address Payment address attributes (not set if blank)
        #
        # @return [Boolean] whether the update succeeded (order and payment were saved)
        #
        def update(params = {})
          set_order_email(params)
          set_shipping_address(params)
          set_payment_address(params)

          persist_update
        end

        # Whether this checkout step is finished.
        # Requires:
        # * order to be valid
        # * payment address to be valid
        # * shipping address to be valid if requires shipping
        #
        # Used for redirecting and summary display in checkout.
        #
        # @return [Boolean]
        #
        def complete?
          order.valid? && billing_complete? && shipping_complete?
        end

        private

        def shipping_options
          @shipping_options ||= ShippingOptions.new(order, shipping).available
        end

        def set_order_email(params)
          if params[:email].present?
            order.email = params[:email]
          elsif user.present?
            order.email = user.email
          end
        end

        def set_shipping_address(params)
          if order.requires_shipping? && params[:shipping_address].present?
            shipping.set_address(params[:shipping_address])
            set_default_shipping_option
          end
        end

        def set_payment_address(params)
          if params[:billing_address].present?
            payment.set_address(params[:billing_address])
          end
        end

        def persist_update
          order.save && payment.save && (shippings.none? || shippings.all?(&:save))
        end

        def set_default_shipping_option
          return unless shipping.address.valid? && !selected_shipping_service_valid?
          shipping.set_shipping_service(default_shipping_option.to_h)
        end

        def selected_shipping_service_valid?
          return false if shipping.shipping_service.blank?
          shipping_options.map(&:name).include?(shipping.shipping_service.name)
        end

        def billing_complete?
          !!payment.address && payment.address.valid?
        end

        def shipping_complete?
          return true unless order.requires_shipping?
          shippings.all?(&:shippable?)
        end
      end
    end
  end
end
