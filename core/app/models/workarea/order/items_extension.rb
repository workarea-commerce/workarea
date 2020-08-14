module Workarea
  class Order
    module ItemsExtension
      def find_existing(sku, attributes = {})
        detect { |item| item.sku == sku && item.attributes_eql?(attributes) }
      end
    end
  end
end
