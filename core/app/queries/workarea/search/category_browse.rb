module Workarea
  module Search
    class CategoryBrowse
      include Query
      include Facets
      include LoadProductResults
      include CategorizationFiltering
      include ProductDisplayRules
      include Pagination

      document Search::Storefront

      def self.available_sorts
        Sort::Collection.new(
          Sort.top_sellers,
          Sort.popularity,
          Sort.newest,
          Sort.price_asc,
          Sort.price_desc
        )
      end

      def query
        {
          bool: {
            must: product_display_query_clauses + category_query_clauses
          }
        }
      end

      def aggregations
        facets.map(&:aggregation).reduce(&:merge)
      end

      def post_filter
        {
          bool: {
            must: facets.map(&:post_filter_clause).reject(&:blank?)
          }
        }
      end

      def sort
        result = current_sort_clauses
        add_displayable_out_of_stock_sort_clause(result)
        result << views_score_sort_clause
        result
      end

      def sorts
        Array(params[:sort])
      end

      def category_id
        if params[:category_ids].respond_to?(:first)
          params[:category_ids].first
        end
      end

      private

      def current_sort_clauses
        sorts.each_with_object([]) do |sort_slug, result|
          if sort_slug.to_s == 'featured'
            result << featured_sort_clause
          else
            current_sort = self.class.available_sorts.find(sort_slug)

            if current_sort.field.present?
              result << {
                current_sort.field => {
                  order: current_sort.direction,
                  missing: '_last',
                  unmapped_type: 'float'
                }
              }
            end
          end
        end
      end

      # We want featured sorts to always be respected so the "displayable when
      # out of stock sort" must always be inserted after the featured sort in
      # the sorts array
      def add_displayable_out_of_stock_sort_clause(sorts)
        displayable_when_out_of_stock_index = 0

        if featured_index = sorts.index(featured_sort_clause)
          displayable_when_out_of_stock_index += featured_index + 1
        end

        sorts.insert(
          displayable_when_out_of_stock_index,
          displayable_when_out_of_stock_sort_clause
        )
      end

      def featured_sort_clause
        {
          "sorts.#{category_id}" => {
            order: 'asc',
            missing: '_last',
            unmapped_type: 'float'
          }
        }
      end

      def views_score_sort_clause
        {
          'sorts.views_score': {
            order: :desc,
            missing: '_last',
            unmapped_type: 'float'
          }
        }
      end
    end
  end
end
