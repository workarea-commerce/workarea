module Workarea
  module Pricing
    class Discount
      # This class allows discounts of the form:
      # * Buy 2, get 1 free
      # * Buy 3, get 1 50% off
      #
      class BuySomeGetSome < Discount
        include Conditions::OrderTotal
        include Conditions::PromoCodes
        include Conditions::UserTags

        # @!attribute purchase_quantity
        #   @return [Integer] the buy quantity
        #
        field :purchase_quantity, type: Integer

        # @!attribute apply_quantity
        #   @return [Integer] the quantity discounted
        #
        field :apply_quantity, type: Integer

        # @!attribute percent_off
        #   @return [Float] the percent off, between 1 and 100
        #
        field :percent_off, type: Float

        # @!attribute max_applications
        #   @return [Integer] the maximum number of applications an item can get
        #
        field :max_applications, type: Integer

        # @!attribute product_ids
        #   @return [Array] for items in these product_ids
        #
        field :product_ids, type: Array, default: []
        list_field :product_ids

        # @!attribute category_ids
        #   @return [Array] for items in these categories
        #
        field :category_ids, type: Array, default: []
        list_field :category_ids

        validates :purchase_quantity, presence: true
        validates :apply_quantity, presence: true
        validates :percent_off, presence: true,
          numericality: { greater_than: 0, less_than_or_equal_to: 100 }

        # @private
        def self.model_name
          Discount.model_name
        end

        # Price changes apply at the item level
        #
        # @return [String]
        #
        self.price_level = 'item'

        # Includes checking the necessary quantity and
        # either a product or category match on an item.
        #
        # @param [Workarea::Order] order
        # @return [Boolean]
        #
        def qualifies?(order)
          super && OrderItemsByProduct.new(order).any? { |p| product_qualifies?(p) }
        end

        # Create the item price adjustments for items that qualify
        # on the passed order.
        #
        # @param [Workarea::Order] order
        #
        def apply(order)
          OrderItemsByProduct.new(order).each do |product|
            next unless product_qualifies?(product)

            ProductApplication.new(self, product).items.each do |item, qty|
              application = ItemApplication.new(self, item, qty)
              next if application.value <= 0

              item.adjust_pricing(
                adjustment_data(application.value, application.apply_quantity)
              )
            end
          end
        end

        # The total minimum quantity an item would need to qualify
        # for receiving this discount.
        #
        # @return [Integer]
        #
        def total_quantity
          purchase_quantity + apply_quantity
        end

        # The float amount version of {BuySomeGetSome#percent_off}
        # for use in price calculation.
        #
        # @return [Float]
        #
        def percent
          1 - (percent_off / 100)
        end

        private

        def product_qualifies?(product)
          product.quantity >= total_quantity && (
            (product_ids.present? && product.id.in?(product_ids)) ||
            (category_ids.present? && product.matches_categories?(category_ids))
          )
        end
      end
    end
  end
end
