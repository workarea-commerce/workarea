module Workarea
  module Pricing
    class Discount
      # This discount allows for basic percent of flat amount
      # off an order total.
      #
      class OrderTotal < Discount
        include FlatOrPercentOff
        include Conditions::OrderTotal
        include Conditions::PromoCodes
        include Conditions::UserTags

        # @private
        def self.model_name
          Discount.model_name
        end

        # Price changes apply at the order level
        #
        # @return [String]
        #
        self.price_level = 'order'
        add_qualifier :has_items?

        # Qualifier method to ensure that the order has
        # some quantity.
        #
        # @param [Workarea::Order] order
        # @return [Boolean]
        #
        def has_items?(order)
          order.quantity > 0
        end

        # Create the price adjustments for amount off the order total.
        # Distributes the discount amount across all items.
        #
        # @param [Pricing::Discount::Order]
        #
        def apply(order)
          total_amount = amount_calculator.calculate(order.subtotal_price)
          distribution = PriceDistributor.for_items(total_amount, order.items)

          order.items.each do |item|
            item_total = distribution[item.id]
            item.adjust_pricing(adjustment_data(item_total, item.quantity))
          end
        end
      end
    end
  end
end
