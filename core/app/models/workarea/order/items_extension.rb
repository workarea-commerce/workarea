module Workarea
  class Order
    module ItemsExtension
      def find_existing(sku, customizations = {})
        customizations.stringify_keys! if customizations.present?

        detect do |item|
          item.sku == sku &&
            item.customizations_eql?(customizations)
        end
      end
    end
  end
end
