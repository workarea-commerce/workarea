module Workarea
  module Pricing
    class Discount
      # This discount allows a quantity of products or products from a certain
      # category to be fixed at a price.
      #
      # For example:
      #   * 2 Shirts for $29
      #   * This product is 3 for $15
      #
      class QuantityFixedPrice < Discount
        include Conditions::OrderTotal
        include Conditions::PromoCodes
        include Conditions::UserTags

        # @!attribute quantity
        #   @return [Integer] the quantity that receives the fixed price
        #
        field :quantity, type: Integer

        # @!attribute max_applications
        #   @return [Integer] the maximum number of times this can be applied
        #
        field :max_applications, type: Integer

        # @!attribute product_ids
        #   @return [Array] ids to eligible {Catalog::Product}s.
        #
        field :product_ids, type: Array, default: []
        list_field :product_ids

        # @!attribute category_ids
        #   @return [Array] ids to eligible {Catalog::Category}s.
        #
        field :category_ids, type: Array, default: []
        list_field :category_ids

        # @!attribute price
        #   @return [Money] the fixed price for the quantity
        #
        field :price, type: Money

        validates :price, presence: true
        validates :quantity, presence: true,
          numericality: { greater_than: 0, allow_blank: true }

        # @private
        def self.model_name
          Discount.model_name
        end

        # Price changes apply at the order level
        #
        # @return [String]
        #
        self.price_level = 'order'

        # These discounts apply if any item matches the catalog
        # requirements.
        #
        # @param [Workarea::Order]
        # @return [Boolean]
        #
        def qualifies?(order)
          super && order.items.any? { |i| item_qualifies?(i) }
        end

        # Create the discount price adjustments on matching items.
        # Redemption can be across items. For example:
        # * discount is quantity 2
        # * item of quantity 1 in category
        # * different item of quantity 1 in same category
        #
        # @param [Pricing::Discount::Order]
        #
        def apply(order)
          applications_calculator = ApplicationCalculator.new(self, order.items)

          item_shares = ItemShares.new(
            self,
            order,
            applications_calculator.applications
          )

          item_shares.each do |id, value|
            item = order.items.detect { |i| i.id == id }
            item.adjust_pricing(adjustment_data(value, item.quantity))
          end
        end

        private

        def item_qualifies?(item)
          return true if product_ids.blank? && category_ids.blank?

          (product_ids.present? && item.matches_products?(product_ids)) ||
            (category_ids.present? && item.matches_categories?(category_ids))
        end
      end
    end
  end
end
