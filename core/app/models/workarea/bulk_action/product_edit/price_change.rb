module Workarea
  class BulkAction
    class ProductEdit < BulkAction
      # Encapsulates all changes made to a given
      # `Workarea::Pricing::Price` by collecting the changes and
      # instantiating `Workarea::BulkAction::ProductEdit::PriceChange::Amount`
      # objects so the new prices can be calculated appropriately.
      class PriceChange
        attr_reader :price, :changes

        # @param [Workarea::Pricing::Price] price - Price record
        # @param [Hash] changes - Parameters from the form
        def initialize(price, changes = {})
          @price = price
          @changes = changes
        end

        # All updates that will be made to the `Workarea::Pricing::Price` record.
        #
        # @return [Hash]
        def attributes
          changes.each_with_object({}) do |(type, value), params|
            amount = Amount.new(price[type], **value.symbolize_keys)
            params[type] = amount.to_m if apply?(amount)
          end
        end

        private

        # Non-generic prices cannot be set to a flat amount. They can only
        # be increased/decreased, or set to a percentage of themselves.
        # This ensures that tiered pricing will not be disabled for a
        # product after a bulk edit occurs.
        #
        # @private
        # @return [Boolean] whether the price can be changed by this bulk edit.
        def apply?(amount)
          price.generic? || amount.apply?
        end
      end
    end
  end
end
