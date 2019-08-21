module Workarea
  module Pricing
    class Discount
      class Product < Discount
        # This discount allows discounting individual products.
        #
        include FlatOrPercentOff
        include Conditions::OrderTotal
        include Conditions::PromoCodes
        include Conditions::ItemQuantity
        include Conditions::UserTags

        # @!attribute product_ids
        #   @return [Array] discount applies to these {Catalog::Product} ids
        #
        field :product_ids, type: Array, default: []
        list_field :product_ids
        validates :product_ids, presence: true

        # @private
        def self.model_name
          Discount.model_name
        end

        # Price changes apply at the item level
        #
        # @return [String]
        #
        self.price_level = 'item'

        # Qualifier method to check whether any items in this order
        # qualify for this discount.
        #
        # @param [Workarea::Order::Item]
        # @return [Boolean]
        #
        def item_qualifies?(item)
          super && item.product_id.in?(product_ids)
        end

        # Creates the price adjustments for the discount on the matching
        # items.
        #
        # @param [Workarea::Order]
        # @return [Workarea::Order]
        #
        def apply(order)
          order.items.each do |item|
            next unless item_qualifies?(item)

            value = amount_calculator.calculate(item.current_unit_price, item.quantity)
            item.adjust_pricing(adjustment_data(value, item.quantity))
          end

          order
        end
      end
    end
  end
end
