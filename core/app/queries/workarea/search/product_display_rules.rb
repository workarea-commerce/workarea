module Workarea
  module Search
    module ProductDisplayRules
      extend ActiveSupport::Concern
      include ReleaseDisplayRules

      def product_display_query_clauses(allow_displayable_when_out_of_stock: true)
        [
          { term: { type: 'product' } },
          { range: { "numeric.variant_count": { gt: 0 } } },
          inventory_display_clause(
            allow_displayable_when_out_of_stock: allow_displayable_when_out_of_stock
          ),
          active_for_release_clause,
          include_current_release_clause
        ]
      end

      def displayable_when_out_of_stock_sort_clause
        {
          'sorts.inventory_score': {
            order: 'desc',
            missing: '_first',
            unmapped_type: 'float'
          }
        }
      end

      private

      def inventory_display_clause(allow_displayable_when_out_of_stock: true)
        result = { bool: { should: [{ range: { 'numeric.inventory': { gt: 0 } } }] } }

        if allow_displayable_when_out_of_stock
          result[:bool][:should] << {
            term: { 'facets.inventory_policies': 'displayable_when_out_of_stock' }
          }
        end

        result
      end
    end
  end
end
