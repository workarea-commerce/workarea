module Workarea
  module Pricing
    class Discount
      class ReconcileTotal
        def initialize(price_adjustments)
          @price_adjustments = price_adjustments
        end

        def over_discounted?
          over_discounted_amount > 0
        end

        def over_discounted_amount
          0.to_m - @price_adjustments.sum
        end

        def perform
          units = discount_adjustments.map do |adjustment|
            { id: adjustment.id, price: adjustment.amount.abs }
          end

          distributor = PriceDistributor.new(over_discounted_amount, units)
          distributor.results.each do |id, value|
            adjustment = discount_adjustments.detect { |a| a.id == id }
            adjustment.amount += value
          end
        end

        private

        def discount_adjustments
          @price_adjustments.select do |adjustment|
            adjustment.data['discount_id'].present?
          end
        end
      end
    end
  end
end
