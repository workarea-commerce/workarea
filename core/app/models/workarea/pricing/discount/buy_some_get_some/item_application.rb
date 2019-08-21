module Workarea
  module Pricing
    class Discount
      # This class is responsible for apply the discount
      # results to a particular {Order::Item}.
      #
      class BuySomeGetSome::ItemApplication
        attr_reader :apply_quantity

        def initialize(discount, item, apply_quantity)
          @discount = discount
          @item = item
          @apply_quantity = apply_quantity
        end

        # The item total before this discount is applied.
        #
        # @return [Money]
        #
        def current_total
          @item.price_adjustments.adjusting('item').sum
        end

        # The portion of the total quantity that should be charged
        # a standard price without discount applied.
        #
        # @return [Integer]
        #
        def standard_quantity
          @item.quantity - @apply_quantity
        end

        # The total price of the number of units that get charged
        # the pre-buy-some-get-some-discount price.
        #
        # @return [Money]
        #
        def standard_units_total
          @item.current_unit_price * standard_quantity
        end

        # The total price of the portion of units that get the
        # discount applied.
        #
        # @return [Money]
        #
        def discounted_units_total
          @item.current_unit_price * @apply_quantity * @discount.percent
        end

        # The total value of this discount on this item,
        # calculated as the total pre-discount and the total
        # of standard units and the discounted units.
        #
        # @return [Money]
        #
        def value
          @value ||= current_total -
            standard_units_total -
            discounted_units_total
        end
      end
    end
  end
end
