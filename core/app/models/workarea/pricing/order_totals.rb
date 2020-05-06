module Workarea
  module Pricing
    class OrderTotals
      def initialize(order, shippings = [])
        @order = order
        @shippings = shippings
      end

      def total
        set_item_totals
        set_subtotal
        set_shipping_totals
        set_tax_totals
        set_discount_total
        set_total
        set_total_value
      end

      def price_adjustments
        @price_adjustments ||= @order.price_adjustments +
                                @shippings.map(&:price_adjustments).reduce(:+)
      end

      private

      def set_item_totals
        @order.items.each do |item|
          item.total_value = item.price_adjustments.reject do |adjustment|
            adjustment.price.in?(%w(tax shipping))
          end.sum(&:amount)

          item.total_price = item.price_adjustments.adjusting('item').sum
        end
      end

      def set_subtotal
        @order.subtotal_price = price_adjustments.adjusting('item').sum
      end

      def set_shipping_totals
        @order.shipping_total = price_adjustments.adjusting('shipping').sum
      end

      def set_tax_totals
        @order.tax_total = price_adjustments.adjusting('tax').sum
      end

      def set_discount_total
        @order.discount_total = price_adjustments.discounts.sum
      end

      def set_total
        @order.total_price = price_adjustments.sum
      end

      def set_total_value
        @order.total_value = @order.total_price - @order.shipping_total - @order.tax_total
      end
    end
  end
end
