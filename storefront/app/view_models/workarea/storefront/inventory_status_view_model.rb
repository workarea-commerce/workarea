module Workarea
  module Storefront
    class InventoryStatusViewModel < ApplicationViewModel
      def message
        return '' if model.nil?

        if inventory.available?
          ::I18n.t('workarea.storefront.products.in_stock')
        elsif inventory.low_inventory?
          ::I18n.t(
            'workarea.storefront.products.few_left',
            quantity: available_to_sell
          )
        elsif inventory.backordered? && backordered_until.present?
          ::I18n.t(
            'workarea.storefront.products.ships_on',
            date: backordered_until.to_date.to_s(:short)
          )
        elsif inventory.backordered?
          ::I18n.t('workarea.storefront.products.backordered')
        elsif inventory.out_of_stock?
          ::I18n.t('workarea.storefront.products.out_of_stock')
        end
      end

      def inventory
        @inventory ||= Inventory::Collection.new(model.id, [model])
      end
    end
  end
end
