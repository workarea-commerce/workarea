module Workarea
  module Pricing
    class Discount
      module Conditions
        module OrderTotal
          extend ActiveSupport::Concern
          OPERATORS = %i(greater_than less_than)

          included do
            # @!attribute order_total_operator
            #   @return [Symbol] the operator (from {OPERATORS}).
            #
            field :order_total_operator, type: Symbol, default: OPERATORS.first

            # @!attribute order_total
            #   @return [Money] the amount to compare against
            #
            field :order_total, type: Money

            add_qualifier :order_total_qualifies?
          end

          # Whether this discount has an order total
          # condition.
          #
          # @return [Boolean]
          #
          def use_order_total?
            order_total.present? && order_total > 0
          end

          # Whether this discount passes its order total
          # conditions.
          #
          # @param [Pricing::Discount::Order] order
          # @return [Boolean]
          #
          def order_total_qualifies?(order)
            return true unless use_order_total?

            if order_total_operator == :less_than
              order.subtotal_price < order_total
            elsif order_total_operator == :greater_than
              order.subtotal_price > order_total
            else
              false # This shouldn't happen
            end
          end
        end
      end
    end
  end
end
