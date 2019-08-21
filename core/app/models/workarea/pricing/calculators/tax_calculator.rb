module Workarea
  module Pricing
    module Calculators
      class TaxCalculator
        include Calculator

        def adjust
          shippings.each do |tmp_shipping|
            next unless tmp_shipping.address.present?

            adjustments_to_tax = price_adjustments_for(tmp_shipping)
            TaxApplier.new(tmp_shipping, adjustments_to_tax).apply
          end
        end

        # If doing split shipping (different items go to different shipping
        # addresses), decorate this method to return the proper price
        # adjustments that match the shipping. (This will have to be added to
        # the UI and saved, probably on the Shipping object)
        #
        # @return [PriceAdjustmentSet]
        #
        def price_adjustments_for(shipping)
          order.price_adjustments
        end
      end
    end
  end
end
