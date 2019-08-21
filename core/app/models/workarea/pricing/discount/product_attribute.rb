module Workarea
  module Pricing
    class Discount
      # This discount allows discounting items based on whether any of the
      # the {Catalog::Product} or {Catalog::Variant} details
      # match.
      #
      class ProductAttribute < Discount
        include FlatOrPercentOff
        include Conditions::OrderTotal
        include Conditions::PromoCodes
        include Conditions::ItemQuantity
        include Conditions::UserTags

        # @!attribute attribute_name
        #   @return [Array] the details name to match
        #
        field :attribute_name, type: String

        # @!attribute attribute_value
        #   @return [Array] the details value to match
        #
        field :attribute_value, type: String

        validates :attribute_name, presence: true
        validates :attribute_value, presence: true

        # @private
        def self.model_name
          Discount.model_name
        end

        # Price changes apply at the item level
        #
        # @return [String]
        #
        self.price_level = 'item'

        # Qualifier method for whether any items in the order
        # match the attribute qualification.
        #
        # @param [Workarea::Order]
        # @return [Boolean]
        #
        def item_qualifies?(item)
          super && ItemQualifier.new(self, item).qualifies?
        end

        # Create the discount price adjustments on items that match
        # the attribute requirements.
        #
        # @param [Pricing::Discount::Order]
        #
        def apply(order)
          order.items.each do |item|
            next unless item_qualifies?(item)

            value = amount_calculator.calculate(item.current_unit_price, item.quantity)
            item.adjust_pricing(adjustment_data(value, item.quantity))
          end
        end
      end
    end
  end
end
