module Workarea
  module Catalog
    class ProductPositions
      class << self
        # Provides output of a products position within a collection
        # of categories. Called with just `product_id`, will lookup and return
        # positions in all categories.
        #
        # Optionally, pass in `categories` or `category_ids` and positions for
        # only these categories will be returned.
        #
        # It can be useful for performance to pass categories in `categories`
        # and avoid the extra query.
        #
        # @param product_id [String]
        # @param categories [Array<Workarea::Catalog::Category>]
        # @param category_ids [Array<String>]
        #
        # @return [Hash]
        #
        def find(product_id, categories: [], category_ids: [])
          categories = if categories.present?
                         categories
                       elsif category_ids.present?
                         Category.any_in(id: category_ids).to_a
                       else
                         Category.any_in(product_ids: [product_id]).to_a
                       end

          categories.reduce({}) do |positions, category|
            index = category.product_ids.index(product_id)
            next positions unless index.present?
            positions[category.id] = index
            positions
          end
        end
      end
    end
  end
end
