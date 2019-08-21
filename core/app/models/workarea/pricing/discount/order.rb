module Workarea
  module Pricing
    class Discount
      # This class is a wrapper for {Workarea::Order}, which includes
      # logic for discount eligibility (e.g. some SKUs can't be discounted).
      #
      # Used in discount calculation, wraps the order and is passed to
      # each discount for qualification and application.
      #
      class Order
        def initialize(order, shippings = [], discount = nil)
          @order = order
          @shippings = Array(shippings)
          @discount = discount
        end

        # Whether to allow sale items in the evaluation of this discount/order
        # combination.
        #
        # @return [Boolean]
        #
        def allow_sale_items?
          @discount.blank? || @discount.allow_sale_items?
        end

        # The shipping associated with the order for the purpose of this
        # pricing request.
        #
        # @return [Array<Shipping>]
        #
        def shippings
          @shippings
        end

        # Only return items that are discountable.
        #
        # @return [Array<Workarea::Order::Item>]
        #
        def items
          @order.items.select(&method(:include_item?))
        end

        # The subtotal, not including items that cannot be discounted.
        #
        # @return [Money]
        #
        def subtotal_price
          items.reduce(0.to_m) do |memo, item|
            memo + item.price_adjustments.sum
          end
        end

        # The total quantity of only discountable items.
        #
        # @return [Integer]
        #
        def quantity
          @quantity ||= items.sum(&:quantity) || 0
        end

        # Add an item to the order (without persisting).
        # Used in {Pricing::Discount::FreeGift} discounts.
        #
        # @return [Workarea::Order::Item]
        #
        def add_item(item)
          @order.items << item
        end

        # Remove an item to the order (without persisting).
        # Used in {Pricing::Discount::FreeGift} discounts.
        #
        # @return [Workarea::Order::Item]
        #
        def remove_item(item)
          @order.items = @order.items.reject { |i| i.id == item.id }
        end

        # Whether or not an item should be included in discount qualification
        # and value calculations.
        #
        # @param [Workarea::Order::Item] item
        # @return [Boolean]
        #
        def include_item?(item)
          item.discountable? &&
            (allow_sale_items? || !item.on_sale?) &&
            !@discount&.excludes_product_id?(item.product_id) &&
            item.category_ids.none? { |cid| @discount&.excludes_category_id?(cid) }
        end

        # @private
        def respond_to_missing?(method_name, include_private = false)
          super || @order.respond_to?(method_name)
        end

        # @private
        def method_missing(sym, *args, &block)
          @order.send(sym, *args, &block) if @order.respond_to?(sym)
        end
      end
    end
  end
end
