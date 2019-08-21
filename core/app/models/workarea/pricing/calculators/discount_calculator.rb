module Workarea
  module Pricing
    module Calculators
      class DiscountCalculator
        include Calculator

        def adjust
          most_valuable_group.apply if most_valuable_group.present?

          # This is mostly for paranoia - it will prevent any sloppy custom
          # discount coding from over-discounting.
          price_adjustment_groups.each do |price_adjustments|
            reconcile = Discount::ReconcileTotal.new(price_adjustments)
            reconcile.perform if reconcile.over_discounted?
          end
        end

        def most_valuable_group
          application_groups.sort { |a, b| a.value <=> b.value }.last
        end

        def application_groups
          @application_groups ||= Discount::ApplicationGroup.calculate(
            discounts,
            order,
            shippings
          )
        end

        private

        def price_adjustment_groups
          [order.price_adjustments] + shippings.map(&:price_adjustments)
        end
      end
    end
  end
end
