module Workarea
  module Pricing
    class Discount
      module Conditions
        module OrderTotal
          extend ActiveSupport::Concern
          OPERATORS = %w(greater_than less_than)

          included do
            # @!attribute order_total_operator
            #   @return [String] the operator (from {OPERATORS}).
            #
            field :order_total_operator, type: String, default: OPERATORS.first

            # @!attribute order_total
            #   @return [Money] the amount to compare against
            #
            field :order_total, type: Money

            add_qualifier :order_total_qualifies?
          end

          # Historically this has been treated like an identifier symbol
          # throughout the admin/UI layer. Ruby 3 + Mongoid will consistently
          # return strings for String-typed fields, so normalize to a symbol.
          def order_total_operator
            super&.to_sym
          end

          def order_total_operator=(value)
            super(value.to_s)
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

            if order_total_operator.to_s == 'less_than'
              order.subtotal_price < order_total
            elsif order_total_operator.to_s == 'greater_than'
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
