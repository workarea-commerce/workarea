module Workarea
  module Storefront
    module CheckInventory
      def check_inventory
        reservation = InventoryAdjustment.new(current_order).tap(&:perform)
        flash[:error] = reservation.errors.to_sentence if reservation.errors.any?
      end
    end
  end
end
