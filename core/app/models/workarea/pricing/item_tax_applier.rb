module Workarea
  module Pricing
    class ItemTaxApplier
      include TaxApplication

      def initialize(address, adjustments_to_tax)
        @address = address
        @adjustments_to_tax = adjustments_to_tax
        @adjustments_by_parent = adjustments_to_tax.grouped_by_parent
      end

      def apply
        @adjustments_to_tax.each { |adjustment| assign_item_tax(adjustment) }
      end

      private

      def assign_item_tax(adjustment)
        order_item = adjustment._parent
        taxable_amount = @adjustments_by_parent[order_item].taxable_share_for(adjustment)
        return if taxable_amount.zero?

        rate = Tax.find_rate(adjustment.data['tax_code'], taxable_amount, @address)
        tax_amounts = calculate_tax_amounts(taxable_amount, rate)
        return if tax_amounts.values.sum.zero?

        order_item.adjust_pricing(
          price: 'tax',
          calculator: self.class.name,
          description: 'Item Tax',
          amount: tax_amounts.values.sum,
          data: tax_amounts.merge(
            'adjustment' => adjustment.id,
            'order_item_id' => adjustment._parent.id,
            'tax_code' => adjustment.data['tax_code']
          )
        )
      end
    end
  end
end
