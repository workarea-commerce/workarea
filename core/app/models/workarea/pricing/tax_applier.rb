module Workarea
  module Pricing
    class TaxApplier
      include GuardNegativePrice

      def initialize(shipping, adjustments_to_tax)
        @shipping = shipping
        @adjustments_to_tax = adjustments_to_tax
        @adjustments_by_parent = adjustments_to_tax.grouped_by_parent
      end

      def shipping_total
        @shipping_total ||= @shipping.price_adjustments.adjusting('shipping').sum
      end

      def apply
        @adjustments_to_tax.each { |a| assign_item_tax(a) }
        assign_shipping_tax if @shipping.shipping_service.present?
      end

      private

      def assign_item_tax(adjustment)
        taxable_amount = taxable_amount_for(adjustment)
        return if taxable_amount.zero?

        rate = Tax.find_rate(
          adjustment.data['tax_code'],
          taxable_amount,
          @shipping.address
        )

        tax_amount = guard_negative_price do
          taxable_amount * rate.percentage
        end

        return if tax_amount.zero?

        @shipping.adjust_pricing(
          price: 'tax',
          calculator: self.class.name,
          description: 'Item Tax',
          amount: tax_amount,
          data: {
            'adjustment' => adjustment.id,
            'order_item_id' => adjustment._parent.id,
            'tax_code' => adjustment.data['tax_code']
          }
        )
      end

      def taxable_amount_for(adjustment)
        order_item = adjustment._parent
        partial_shipping_quantity = @shipping.quantities[order_item.id.to_s].to_i
        return 0 if @shipping.partial? && partial_shipping_quantity.zero?

        total = @adjustments_by_parent[order_item].taxable_share_for(adjustment)
        total *= partial_shipping_quantity / order_item.quantity.to_f if @shipping.partial?
        total
      end

      def assign_shipping_tax
        return unless shipping_total > 0

        tax_rate = Tax.find_rate(
          @shipping.shipping_service.tax_code,
          shipping_total,
          @shipping.address
        )

        return unless tax_rate.charge_on_shipping?

        amount = shipping_total * tax_rate.percentage

        if amount > 0
          @shipping.adjust_pricing(
            price: 'tax',
            calculator: self.class.name,
            description: 'Shipping Tax',
            amount: amount,
            data: {
              'shipping_service_tax' => true,
              'tax_code' => tax_rate.category.code
            }
          )
        end
      end
    end
  end
end
