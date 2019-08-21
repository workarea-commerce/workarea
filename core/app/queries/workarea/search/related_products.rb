module Workarea
  module Search
    class RelatedProducts
      include Query
      include LoadProductResults
      include ProductDisplayRules

      document Search::Storefront

      def query
        {
          bool: {
            must: product_display_query_clauses(allow_displayable_when_out_of_stock: false) +
                    more_like_this_query_clauses +
                    primary_navigation_query_clauses +
                    exclusion_query_clauses
          }
        }
      end

      def size
        10
      end

      private

      def more_like_this_query_clauses
        [
          {
            more_like_this: {
              fields: %w(content.name content.category_name content.facets),
              min_term_freq: 1,
              min_doc_freq: 2,
              ids: search_product_ids,
              like_text: like_text
            }
          }
        ]
      end

      # Restrict to primary nav matches to prevent disparate matches
      def primary_navigation_query_clauses
        return [] if primary_navigations.blank?
        [{ terms: { 'facets.category' => primary_navigations } }]
      end

      def exclusion_query_clauses
        return [] if exclude_search_product_ids.blank?

        [
          {
            bool: { must_not: { ids: { values: exclude_search_product_ids } } }
          }
        ]
      end

      def products
        @products ||= Catalog::Product.any_in(id: Array(params[:product_ids])).to_a
      end

      def search_product_ids
        @search_product_ids ||= products.map { |p| Storefront::Product.new(p).id }
      end

      def exclude_search_product_ids
        @exclude_search_product_ids ||=
          begin
            catalog_ids = Array(params[:exclude_product_ids])
            products = Catalog::Product.any_in(id: catalog_ids).to_a
            products.map { |p| Storefront::Product.new(p).id }
          end
      end

      def categories
        @categories ||= Catalog::Category
                          .any_in(id: Array(params[:category_ids]))
                          .to_a
      end

      def searches
        QueryString.new(Array(params[:searches]).join(' ')).sanitized
      end

      def like_text
        "#{categories.map(&:name).join(' ')} #{searches}"
      end

      def primary_navigations
        @primary_navigations ||= products
          .map { |p| ProductPrimaryNavigation.new(p).name }
          .reject(&:blank?)
          .uniq
      end
    end
  end
end
