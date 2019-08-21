module Workarea
  module Pricing
    module Calculators
      class CustomizationsCalculator
        include Calculator

        def adjust
          order.items.each do |item|
            next unless item.customizations['pricing_sku'].present?

            price = pricing.for_sku(
              item.customizations['pricing_sku'],
              quantity: item.quantity
            )

            unit = price.sell

            if unit > 0
              item.adjust_pricing(
                price: 'item',
                amount: unit * item.quantity,
                quantity: item.quantity,
                calculator: self.class.name,
                description: 'Customizations',
                data: { 'tax_code' => price.tax_code }
              )
            end
          end
        end
      end
    end
  end
end
