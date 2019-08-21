module Workarea
  module Pricing
    class Discount
      class BuySomeGetSome::OrderItemsByProduct
        include Enumerable

        class Product < Struct.new(:id, :items, :quantity, :category_ids)
          def matches_categories?(*ids)
            match_ids = Array(ids).flatten.map(&:to_s)
            (category_ids.map(&:to_s) & match_ids).any?
          end
        end

        delegate :any?, :empty?, :each, to: :products

        def initialize(order)
          @order = order
        end

        # Aggregate product that reflects all items in the
        # order that share a product_id
        #
        # @return [Array<OrderProducts::Product>]
        #
        def products
          @products ||= @order.items.group_by(&:product_id).map do |id, items|
            Product.new(
              id,
              items,
              items.sum(&:quantity),
              items.flat_map(&:category_ids).compact.uniq
            )
          end
        end
      end
    end
  end
end
