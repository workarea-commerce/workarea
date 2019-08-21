module Workarea
  module Pricing
    class Discount
      # This discount allows setting a fixed price for specific
      # shipping services.
      #
      # For example:
      #   * Free ground shipping on orders over $100
      #   * $5 shipping with this promo code
      #
      class Shipping < Discount
        include Conditions::OrderTotal
        include Conditions::PromoCodes
        include Conditions::UserTags

        # @!attribute shipping_service
        #   @return [String] the {Shipping::Service} name to apply
        #
        field :shipping_service, type: String

        # @!attribute amount
        #
        field :amount, type: Money

        validates :shipping_service, presence: true
        validates :amount, presence: true

        # @private
        def self.model_name
          Discount.model_name
        end

        # Price changes apply at the shipping level
        #
        # @return [String]
        #
        self.price_level = 'shipping'
        add_qualifier :matching_shipping_service?

        # Qualifier method for whether the order has a matching
        # shipping address.
        #
        # @param [Pricing::Discount::Order]
        #
        def matching_shipping_service?(order)
          order.shippings.any? do |shipping|
            shipping_matches_shipping_service?(shipping)
          end
        end

        # Add the discount price adjustments to the qualifying shipping.
        #
        # @param [Pricing::Discount::Order]
        #
        def apply(order)
          order.shippings.each do |shipping|
            next unless shipping_matches_shipping_service?(shipping)
            apply_to_shipping(shipping)
          end
        end

        private

        def shipping_matches_shipping_service?(shipping)
          shipping.shipping_service.present? &&
            shipping.shipping_service.name.present? &&
            shipping.shipping_service.name == shipping_service
        end

        def apply_to_shipping(shipping)
          shipping_total = shipping.price_adjustments.adjusting('shipping').sum
          value = shipping_total - amount
          return if value < 0

          shipping.adjust_pricing(adjustment_data(value, 1))
        end
      end
    end
  end
end
