module Workarea
  module Search
    class Storefront
      class Product
        module Sorting
          # A hash of the position the product has in each category. Used for featured
          # sorting.
          #
          # @return [Hash]
          #
          def category_positions
            Catalog::ProductPositions.find(
              model.id,
              categories: categorization.to_models
            )
          end

          def search_positions
            Workarea::Search::Customization.positions_for_product(model.id)
          end
        end
      end
    end
  end
end
