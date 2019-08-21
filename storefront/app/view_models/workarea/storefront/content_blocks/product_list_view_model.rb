module Workarea
  module Storefront
    module ContentBlocks
      class ProductListViewModel < ContentBlockViewModel

        def locals
          super.merge(products: products)
        end

        def products
          return [] unless data['products'].present?

          @products ||= Catalog::Product
                          .find_ordered_for_display(data['products'])
                          .map { |product| ProductViewModel.wrap(product) }
        end
      end
    end
  end
end
