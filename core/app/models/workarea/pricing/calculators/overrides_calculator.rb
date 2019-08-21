module Workarea
  module Pricing
    module Calculators
      class OverridesCalculator
        include Calculator

        def adjust
          return unless override.present?

          override.adjusts_subtotal? ? adjust_subtotal : adjust_items
          adjust_shipping
        end

        private

        def adjust_subtotal
          return unless override.adjusts_subtotal?

          distributions = PriceDistributor.for_items(
            override.subtotal_adjustment,
            order.items
          ).results

          order.items.each do |item|
            item.adjust_pricing(
              price_adjustment_data.merge(
                price: 'order',
                quantity: item.quantity,
                amount: guard_negative_price(distributions[item.id], item)
              )
            )
          end
        end

        def adjust_items
          return unless override.adjusts_items?

          order.items.each do |item|
            unit_price = override.item_price_for_id(item.id)
            next unless unit_price.present?

            adjustment = (unit_price * item.quantity) - item.price_adjustments.sum
            next if adjustment.zero?

            item.adjust_pricing(
              price_adjustment_data.merge(
                price: 'item',
                quantity: item.quantity,
                amount: guard_negative_price(adjustment, item)
              )
            )
          end
        end

        def adjust_shipping
          return unless override.adjusts_shipping?

          distributions =
            distribute_shipping_adjustment(override.shipping_adjustment)

          shippings.each do |shipping|
            shipping.adjust_pricing(
              price_adjustment_data.merge(
                price: 'shipping',
                amount: guard_negative_price(distributions[shipping.id], shipping)
              )
            )
          end
        end

        private

        def override
          @override ||= Override.find(order.id)
        rescue Mongoid::Errors::DocumentNotFound
          nil # No override to apply
        end

        def price_adjustment_data
          {
            calculator: self.class.name,
            description: I18n.t('workarea.pricing_overrides.description'),
            data: {
              created_by_id: override.created_by_id,
              override: true
            }
          }
        end

        def guard_negative_price(amount, source)
          return amount if amount.positive?
          [source.price_adjustments.sum, amount.abs].min * -1
        end

        def distribute_shipping_adjustment(amount)
          shipping_units = shippings.map do |shipping|
            { id: shipping.id, price: shipping.base_price }
          end

          PriceDistributor.new(amount, shipping_units).results
        end
      end
    end
  end
end
