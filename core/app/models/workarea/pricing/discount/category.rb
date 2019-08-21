module Workarea
  module Pricing
    class Discount
      # This class allows discounts to any products categorized
      # in one or many categories.
      #
      class Category < Discount
        include FlatOrPercentOff
        include Conditions::OrderTotal
        include Conditions::PromoCodes
        include Conditions::ItemQuantity
        include Conditions::UserTags

        # @!attribute category_ids
        #   @return [Integer] the ids for the {Catalog::Category}
        #
        field :category_ids, type: Array, default: []
        list_field :category_ids

        validates :category_ids, presence: true

        # @private
        def self.model_name
          Discount.model_name
        end

        # Price changes apply at the item level
        #
        # @return [String]
        #
        self.price_level = 'item'

        # Whether the order item qualifies based on category
        # and quantity requirements
        #
        # @param [Workarea::Order::Item] item
        # @return [Boolean]
        #
        def item_qualifies?(item)
          super && item.matches_categories?(category_ids)
        end

        # Create the item price adjustments for items that qualify
        # match the #category_ids.
        #
        # @param [Pricing::Discount::Order] order
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
