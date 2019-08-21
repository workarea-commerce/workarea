module Workarea
  module Admin
    module PriceAdjustmentsHelper
      def price_adjustment_description_for(adjustment)
        result = adjustment.description

        if adjustment.discount?
          discount = Pricing::Discount.find(adjustment.data['discount_id']) rescue nil

          if discount.present?
            link_to discount.name, url_for(discount)
          else
            result
          end
        else
          result
        end
      end
    end
  end
end
