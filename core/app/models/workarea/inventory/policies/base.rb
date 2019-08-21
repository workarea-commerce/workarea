module Workarea
  module Inventory
    module Policies
      class Base
        attr_reader :sku

        def initialize(sku)
          @sku = sku
        end

        # Whether this SKU should contribute to being
        # displayed with resepect to inventory.
        #
        # @return [Boolean]
        #
        def displayable?
          raise(NotImplementedError)
        end

        # Returns the quantity of available units of the SKU for sale
        #
        # @return [Integer] count
        #
        def available_to_sell
          raise(NotImplementedError)
        end

        # Decrement the inventory required to represent a purchase
        # for this policy. Commonly, this would do some logic to decide
        # how many units to capture and call {Sku}#capture.
        #
        # Returns a hash with results to record how many were captured,
        # for later rolling back if necessary. Hash has keys for
        # available and backordered counts.
        #
        # @return [Hash]
        #
        def purchase(quantity)
          raise(NotImplementedError)
        end
      end
    end
  end
end
