module Workarea
  class OrderMerge
    attr_reader :original

    def initialize(original)
      @original = original
    end

    def merge(other)
      return unless original.valid?

      other.items.each do |item|
        next if original.has_sku?(item.sku)

        attributes = OrderItemDetails.find!(item.sku, product_id: item.product_id).to_h

        original.add_item(
          attributes.merge(
            product_id: item.product_id,
            sku: item.sku,
            quantity: item.quantity,
            customizations: item.customizations
          )
        )
      end

      other.promo_codes.each do |code|
        original.add_promo_code(code)
      end

      original.save!
    end
  end
end
