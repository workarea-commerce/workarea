module Workarea
  module Pricing
    class Discount
      module Conditions
        module ItemQuantity
          extend ActiveSupport::Concern

          included do
            # @!attribute item_quantity
            #   @return [Integer] the number to check against
            #
            field :item_quantity, type: Integer, default: 0
            add_qualifier :items_qualify?
          end

          # Whether this discount uses item quantity
          # as a condition.
          #
          # @return [Boolean]
          #
          def item_quantity?
            item_quantity.present? && item_quantity > 0
          end

          # Whether this discount's item quantity passes
          # for this order.
          #
          # @param [Pricing::Discount::Order] order
          # @return [Boolean]
          #
          def items_qualify?(order)
            order.items.any? { |item| item_qualifies?(item) }
          end

          def item_qualifies?(item)
            !item_quantity? || item.quantity >= item_quantity
          end
        end
      end
    end
  end
end
