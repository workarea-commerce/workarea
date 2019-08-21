module Workarea
  module Storefront
    class InventoryStatusViewModel < ApplicationViewModel
      def message
        return '' if model.nil?
        if purchasable?(Workarea.config.low_inventory_threshold) &&
          !backordered?
          ::I18n.t('workarea.storefront.products.in_stock')
        elsif purchasable? && !backordered?
          ::I18n.t(
            'workarea.storefront.products.few_left',
            quantity: available_to_sell
          )
        elsif backordered? && backordered_until.present?
          ::I18n.t(
            'workarea.storefront.products.ships_on',
            date: backordered_until.to_date.to_s(:short)
          )
        elsif backordered?
          ::I18n.t('workarea.storefront.products.backordered')
        else
          ::I18n.t('workarea.storefront.products.out_of_stock')
        end
      end
    end
  end
end
