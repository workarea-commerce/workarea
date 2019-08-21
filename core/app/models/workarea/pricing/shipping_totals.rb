module Workarea
  module Pricing
    class ShippingTotals
      def initialize(shipping)
        @shipping = shipping
        @price_adjustments = PriceAdjustmentSet.new(
          @shipping.price_adjustments
        )
      end

      def total
        set_shipping_total
        set_tax_total
      end

      def set_shipping_total
        relevant_adjustments = @price_adjustments.adjusting('shipping')
        @shipping.shipping_total = relevant_adjustments.sum
      end

      def set_tax_total
        relevant_adjustments = @price_adjustments.adjusting('tax')
        @shipping.tax_total = relevant_adjustments.sum
      end
    end
  end
end
