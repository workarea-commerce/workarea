module Workarea
  module Pricing
    module Calculators
      class TaxCalculator
        include Calculator
        delegate :tax_exempt?, to: :user, allow_nil: true

        def adjust
          adjust_tax_exempt_items_tax && return if tax_exempt?
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

        def adjust_tax_exempt_items_tax
          shippings.each do |tmp_shipping|
            next unless tmp_shipping.address.present?

            price_adjustments_for(tmp_shipping).each do |adjustment|
              tmp_shipping.adjust_pricing(
                price: 'tax',
                calculator: self.class.name,
                description: 'Item Tax',
                amount: 0.to_m,
                data: {
                  'adjustment' => adjustment.id,
                  'order_item_id' => adjustment._parent.id,
                  'tax_code' => adjustment.data['tax_code'],
                  'tax_exempt' => user.tax_exempt?
                }
              )
            end
          end
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

        private

        def user
          begin
            return @user if defined? @user
            return unless order.user_id.present?
            @user = User.find(order.user_id)
          rescue Mongoid::Errors::DocumentNotFound, Mongoid::Errors::InvalidFind
            @user = nil
          end
        end
      end
    end
  end
end
