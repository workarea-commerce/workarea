module Workarea
  module Storefront
    module ContentBlocks
      class CategorySummaryViewModel < ContentBlockViewModel
        include ProductBrowsing

        def locals
          super.merge(
            category: category,
            products: products
          )
        end

        def category
          return @category if defined?(@category)
          @category = Catalog::Category.where(id: data['category']).first
        end

        def products
          return [] unless category.present?
          @products ||= search.results.take(product_count).map do |result|
            ProductViewModel.wrap(result[:model])
          end
        end

        def product_count
          Workarea.config.category_summary_product_count
        end

        private

        def search
          @search ||= Search::CategoryBrowse.new(
            category_ids: [category.id],
            rules: category.product_rules,
            page: 1,
            sort: sorts
          )
        end

        def sorts
          @current_sorts ||=
            if category.featured_products?
              [:featured, category.default_sort]
            else
              [category.default_sort]
            end
        end
      end
    end
  end
end
