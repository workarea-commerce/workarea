module Workarea
  module Storefront
    module ContentBlocks
      class ProductInsightsViewModel < ContentBlockViewModel
        def products
          @products ||= ProductViewModel.wrap(
            add_fallbacks(find_insight_products(data[:type]))
          )
        end

        private

        def find_insight_products(type)
          return [] if type.blank?

          klass = "Workarea::Insights::#{type.to_s.remove(/\s/).camelize}".constantize
          ids = klass.current.results.map { |r| r['product_id'] }
          Catalog::Product.find_ordered_for_display(ids)
        end

        def add_fallbacks(products)
          return products if products.count >= results_count

          results = products +
            find_insight_products(:top_products) +
            find_insight_products(:trending_products)

          results.uniq!(&:id)
          return results.take(results_count) if results.count >= results_count

          results.push(*newest_products)
          results.uniq!(&:id)
          results.take(results_count)
        end

        def newest_products
          @newest_products ||= Catalog::Product.recent(results_count * 2).select(&:active?)
        end

        def results_count
          Workarea.config.product_insights_count
        end
      end
    end
  end
end
