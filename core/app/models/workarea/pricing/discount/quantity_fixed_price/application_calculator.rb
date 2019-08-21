module Workarea
  module Pricing
    class Discount
      # Responsible for calcuating a how many applicaitons a given
      # set of items should recieve a {QuantityFixedPrice}.
      # Limits at max application is set.
      #
      class QuantityFixedPrice::ApplicationCalculator
        delegate :product_ids, :category_ids, :max_applications, :quantity,
          to: :@discount

        def initialize(discount, items)
          @discount = discount
          @items = items
        end

        # The number of applications these items can recieve.
        #
        # @return [Integer]
        #
        def applications
          if max_applications.present? &&
               potential_applications > max_applications
            max_applications
          else
            potential_applications
          end
        end

        private

        def potential_applications
          @potential_applications ||=
            begin
              result = 0
              current_quantity = 0

              @items.each do |item|
                next unless item.matches_products?(product_ids) || item.matches_categories?(category_ids)

                item.quantity.times do
                  current_quantity += 1

                  if current_quantity == quantity
                    result += 1
                    current_quantity = 0
                  end
                end
              end

              result
            end
        end
      end
    end
  end
end
