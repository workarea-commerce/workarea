module Workarea
  class Checkout
    module Steps
      class Base
        attr_reader :checkout

        delegate :order, :user, :payment, :payment_profile, :shipping, :shippings,
          to: :checkout, allow_nil: true

        def initialize(checkout)
          @checkout = checkout
        end

        # Update data related to current step of checkout
        #
        # @param [Hash] params
        #
        # @return [Boolean] whether the update succeeded
        #
        def update(params = {})
          raise(NotImplementedError, "#{self.class} must implement the #update method")
        end

        # Whether this checkout step is finished.
        # Used for redirecting and summary display in checkout.
        #
        # @return [Boolean]
        #
        def complete?
          raise(NotImplementedError, "#{self.class} must implement the #complete? method")
        end
      end
    end
  end
end
