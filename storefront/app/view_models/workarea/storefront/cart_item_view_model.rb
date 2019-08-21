module Workarea
  module Storefront
    class CartItemViewModel < OrderItemViewModel
      def inventory_status
        InventoryStatusViewModel.new(
          options[:inventory] || Inventory::Sku.find_or_create_by(id: sku)
        ).message
      end
    end
  end
end
