module Workarea
  class BulkAction
    class ProductEdit < BulkAction
      class PriceChange
        # Calculates the new amount of a given current price using
        # directives from the Bulk Product Edit form.
        class Amount
          class InvalidError < RuntimeError
            def initialize(amount)
              super "Invalid Amount From #{amount.inspect}"
            end
          end

          attr_reader :current, :type, :action, :amount

          # @param [Money] current - Current price
          # @param [String] action - Either "set", "increase", or "decrease"
          # @param [String] type - Either "flat" or "percentage"
          # @param [String] amount - Amount to increase/set/decrease by
          def initialize(current, action:, type:, amount: 0.to_m)
            @current = current || 0.to_m
            @action = action
            @type = type
            @amount = amount
          end

          # Test whether this amount is not setting a flat amount. Used
          # in the `PriceChange` class when determining whether to
          # perform an update. Non-generic prices are not updated when
          # the admin chooses to set a flat amount for all prices in the
          # product's SKUs.
          #
          # @return [Boolean]
          def apply?
            return true if action.in? %w[increase decrease]

            type == 'percentage'
          end

          # Calculate the new price amount for the given set of parameters
          # and current price.
          #
          # @param [Hash] params - The value of the price param from the
          # form.
          # @param [Numeric] current - Current price.
          # @return [Money] New price.
          # @raise [Workarea::BulkAction::ProductEdit::Amount::InvalidError]
          #        if the amount cannot be calculated
          def to_m
            if type == 'flat' && action == 'set'
              amount.to_m
            elsif type == 'percentage' && action == 'set'
              applied_percent.to_m
            elsif type == 'flat' && action == 'increase'
              current.to_m + amount.to_m
            elsif type == 'flat' && action == 'decrease'
              current.to_m - amount.to_m
            elsif type == 'percentage' && action == 'increase'
              current.to_m + applied_percent
            elsif type == 'percentage' && action == 'decrease'
              current.to_m - applied_percent
            else
              raise InvalidError, self
            end
          end

          private

          # Calculate the percentage of a given price.
          #
          # @private
          # @return [Float] Percentage of the current price.
          def applied_percent
            current * (amount.to_f / 100)
          end
        end
      end
    end
  end
end
