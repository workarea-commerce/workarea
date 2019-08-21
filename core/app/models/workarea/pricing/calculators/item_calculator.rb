module Workarea
  module Pricing
    module Calculators
      class ItemCalculator
        include Calculator

        def adjust
          order.items.each do |item|
            price = pricing.for_sku( item.sku, quantity: item.quantity)

            item.adjust_pricing(
              price: 'item',
              quantity: item.quantity,
              calculator: self.class.name,
              amount: price.sell * item.quantity,
              description: 'Item Subtotal',
              data: {
                'on_sale' => price.on_sale?,
                'original_price' => price.regular.to_f,
                'tax_code' => price.tax_code
              }
            )
          end
        end
      end
    end
  end
end
