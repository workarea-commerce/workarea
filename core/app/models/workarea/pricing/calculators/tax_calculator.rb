module Workarea
  module Pricing
    module Calculators
      class TaxCalculator
        include Calculator

        def adjust
          adjust_shipped_items_tax
          adjust_not_shipped_items_tax
        end

        def adjust_shipped_items_tax
          shippings.each do |tmp_shipping|
            next unless tmp_shipping.address.present?

            adjustments_to_tax = price_adjustments_for(tmp_shipping)
            TaxApplier.new(tmp_shipping, adjustments_to_tax).apply
          end
        end

        def adjust_not_shipped_items_tax
          return unless payment&.address.present?

          ItemTaxApplier.new(
            payment.address,
            not_shipped_items_price_adjustments
          ).apply
        end

        def shipped_items_price_adjustments
          PriceAdjustmentSet.new(
            order.items.select(&:shipping?).flat_map(&:price_adjustments)
          )
        end

        def not_shipped_items_price_adjustments
          PriceAdjustmentSet.new(
            order.items.reject(&:shipping?).flat_map(&:price_adjustments)
          )
        end

        # @deprecated As of v3.5, this class supports applying tax directly to
        # items when they do not require shipping. As a result tax calculation
        # is split on this distinction and this method is no longer sufficient.
        # Instead modify the appropriate method to change the set of price
        # adjustments to consider for tax calculation.
        #
        # @return [PriceAdjustmentSet]
        #
        def price_adjustments_for(shipping)
          shipped_items_price_adjustments
        end
      end
    end
  end
end
