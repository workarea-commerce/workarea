module Workarea
  module Pricing
    class Discount
      # This class does the calculation of how much each item should
      # receive off for a {QuantityFixedPrice}.
      #
      # It acts like a hash, where the key is the item id and the value
      # is the amount that item should receive off.
      #
      class QuantityFixedPrice::ItemShares
        delegate :[], :each, to: :hash
        delegate :price, :quantity, :product_ids, :category_ids, to: :@discount

        def initialize(discount, order, applications)
          @discount = discount
          @order = order
          @applications = applications
        end

        private

        def hash
          @hash ||=
            begin
              results = Hash.new(0.to_m)

              @applications.times do |i|
                current_units = qualified_units.slice!(0, quantity)
                total_price = current_units.sum { |u| u[:price] }
                total_value = total_price - price

                distribution = PriceDistributor.new(total_value, current_units)
                distribution.each do |id, value|
                  results[id] += value
                end
              end

              results
            end
        end

        def qualified_units
          @qualified_units ||=
            begin
              result = []

              @order.items.each do |item|
                next unless item.matches_products?(product_ids) ||
                  item.matches_categories?(category_ids)

                item.quantity.times do
                  result << { id: item.id, price: item.current_unit_price }
                end
              end

              result.sort! { |a, b| b[:price] <=> a[:price] }
              result.pop until result.length % quantity == 0
              result
            end
        end
      end
    end
  end
end
