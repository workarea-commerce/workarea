module Workarea
  class InventoryAdjustment
    attr_reader :cart, :errors

    def initialize(cart)
      @cart = cart
    end

    def perform
      @errors = []

      insufficiencies.each do |sku, quantity_short|
        item = cart.items.detect { |i| i.sku == sku }
        next unless item.present? && quantity_short > 0

        new_quantity = item.quantity - quantity_short

        if new_quantity == 0
          cart.remove_item(item.id)
          @errors << I18n.t('workarea.errors.messages.sku_unavailable', sku: sku)
        else
          cart.update_item(item.id, quantity: new_quantity)
          @errors << I18n.t(
            'workarea.errors.messages.sku_limited_quantity',
            quantity: new_quantity,
            sku: item[:sku]
          )
        end
      end
    end

    private

    def insufficiencies
      @insufficiencies ||= Inventory.find_insufficiencies(serialized_items)
    end

    def serialized_items
      cart.items.inject({}) do |memo, item|
        memo[item.sku] = item.quantity
        memo
      end
    end
  end
end
