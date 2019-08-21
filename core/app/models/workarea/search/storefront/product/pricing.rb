module Workarea
  module Search
    class Storefront
      class Product
        module Pricing
          # The price of this product for the search index used for sorting.
          # It is the lowest sellable price for any SKUs that belong to the
          # product. Converted to a float so JSON encoding is not applied to
          # {Money} when being put into the index.
          #
          # @return [Float]
          #
          def sort_price
            pricing.sell_min_price.to_f
          end

          # The prices of this product for the search index. It is the collection
          # of sellable prices for any SKUs that belong to the product if price
          # ranges are enabled. Otherwise it is the lowest sellable price
          # for any SKUs that belong to the product. Converted to a float so JSON
          # encoding is not applied to {Money} when being put into the index.
          #
          # @return [Array]
          #
          def price
            if pricing.all_selling_prices.present?
              pricing.all_selling_prices.map(&:to_f)
            else
              [0.0]
            end
          end

          # Whether or not the product is considered on sale. Determined by having
          # a pricing sku that is set to be on sale.
          #
          # @return [Boolean]
          #
          def on_sale?
            pricing.on_sale?
          end

          # The product pricing based on the available SKUs to get the
          # correct index data.
          #
          # @return [Pricing::Collection]
          #
          def pricing
            @pricing ||= Workarea::Pricing::Collection.new(
              skus_with_displayable_inventory
            )
          end
        end
      end
    end
  end
end
