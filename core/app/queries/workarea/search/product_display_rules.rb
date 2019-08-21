module Workarea
  module Search
    module ProductDisplayRules
      def product_display_query_clauses(allow_displayable_when_out_of_stock: true)
        [
          { term: { type: 'product' } },
          { range: { "numeric.variant_count": { gt: 0 } } },
          inventory_display_clause(
            allow_displayable_when_out_of_stock: allow_displayable_when_out_of_stock
          ),
          active_for_release_clause
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

      def active_for_release_clause
        if Release.current.blank?
          { term: { 'active.now' => true } }
        else
          {
            bool: {
              should: [
                { term: { "active.#{Release.current.id}" => true } },
                {
                  bool: {
                    must: [
                      { term: { 'active.now' => true } },
                      {
                        bool: {
                          must_not: {
                            exists: { field: "active.#{Release.current.id}" }
                          }
                        }
                      }
                    ]
                  }
                }
              ]
            }
          }
        end
      end
    end
  end
end
