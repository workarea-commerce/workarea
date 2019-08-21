module Workarea
  module Pricing
    class Discount
      # This class is responsible determining the
      # distribution of the discount across items
      # within a product.
      #
      class BuySomeGetSome::ProductApplication

        def initialize(discount, product)
          @discount = discount
          @product = product
        end

        # Determines the quantity of each item for the product
        # that can have the discount applied.
        #
        # @return [Hash]
        #
        def items
          @items ||= begin
            remaining = standard_quantity

            items_by_price.inject({}) do |hash, item|
              if remaining > item.quantity
                apply_quantity = 0
                remaining -= item.quantity
              else
                apply_quantity = item.quantity - remaining
                remaining = 0
              end

              hash[item] = apply_quantity
              hash
            end
          end
        end

        # How many times the discount can be applied across
        # items in the order for this product.
        #
        # @return [Integer]
        #
        def applications
          @applications ||=
            begin
              applications = @product.quantity / @discount.total_quantity

              if @discount.max_applications.present? &&
                applications > @discount.max_applications
                @discount.max_applications
              else
                applications
              end
            end
        end

        # Quantity that should have standard pricing across items
        # for the product.
        #
        # @return [Integer]
        #
        def standard_quantity
          @product.quantity - applications * @discount.apply_quantity
        end

        # Items for the product sorted by the unit price of the
        # item, ordered highest to lowest
        #
        # @return [Array<Workarea::Order::Item>]
        #
        def items_by_price
          @product.items.sort_by do |item|
            item.price_adjustments
              .adjusting('item')
              .map(&:unit)
              .sum
          end
        end
      end
    end
  end
end
