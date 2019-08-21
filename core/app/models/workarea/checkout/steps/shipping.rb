module Workarea
  class Checkout
    module Steps
      class Shipping < Base
        class NoAvailableShippingOption < RuntimeError; end

        # The checkout shipipng options that are available for this order.
        #
        # @return [Checkout::ShippingOptions]
        #
        def shipping_options
          @shipping_options ||= ShippingOptions.new(order, shipping)
        end

        # Update the shipping step of checkout. This includes:
        # * shipping service
        #
        # A default shipping service will probably be set before getting
        # to this point of the checkout.
        #
        # @param [Hash] params
        # @option params [String] :shipping_service
        #
        # @raise [Checkout::Steps::Shipping::NoAvailableShippingOption]
        #
        # @return [Boolean] whether the update succeeded
        #
        def update(params = {})
          unless order.requires_shipping?
            clean_shipping
            return true
          end

          update_shipping_service(params)
          add_shipping_instructions(params)
          persist_update
        end

        # Whether this checkout step is finished.
        # Requires order to be valid, since a default shipping service will always
        # be set.
        #
        # @return [Boolean]
        #
        def complete?
          order.valid? && (!order.requires_shipping? || shipping.valid?)
        end

        private

        def clean_shipping
          Workarea::Shipping.where(order_id: order.id).destroy_all
        end

        def update_shipping_service?(params)
          shipping.address.try(:valid?) &&
            !(shipping.shipping_service.present? &&
              params[:shipping_service].blank?)
        end

        def update_shipping_service(params)
          return unless update_shipping_service?(params)

          shipping_option = shipping_options.find_valid(
            params[:shipping_service]
          )

          raise NoAvailableShippingOption if shipping_option.blank?
          shipping.set_shipping_service(shipping_option.to_h)
        end

        def add_shipping_instructions(params)
          shipping.instructions = params[:shipping_instructions].to_s.strip
        end

        def persist_update
          shipping.save && order.save
        end
      end
    end
  end
end
