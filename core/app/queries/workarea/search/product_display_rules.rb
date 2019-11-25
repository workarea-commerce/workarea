module Workarea
  module Search
    module ProductDisplayRules
      extend ActiveSupport::Concern

      def product_display_query_clauses(allow_displayable_when_out_of_stock: true)
        [
          { term: { type: 'product' } },
          { range: { "numeric.variant_count": { gt: 0 } } },
          inventory_display_clause(
            allow_displayable_when_out_of_stock: allow_displayable_when_out_of_stock
          ),
          active_for_segments_clause,
          preview_current_release_clause
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

      def inventory_display_clause(allow_displayable_when_out_of_stock: true)
        result = { bool: { should: [{ range: { 'numeric.inventory': { gt: 0 } } }] } }

        if allow_displayable_when_out_of_stock
          result[:bool][:should] << {
            term: { 'facets.inventory_policies': 'displayable_when_out_of_stock' }
          }
        end

        result
      end

      def active_for_segments_clause
        {
          bool: {
            must: [
              { term: { 'active.now' => true } },
              {
                bool: {
                  should: [
                    { bool: { must_not: { exists: { field: 'active_segment_ids' } } } },
                    { terms: { 'active_segment_ids' => Segment.current.map(&:id) } }
                  ]
                }
              }
            ]
          }
        }
      end

      def preview_current_release_clause
        if Release.current.blank?
          {
            bool: {
              minimum_should_match: 1,
              should: [
                { term: { release_id: 'live' } },
                { bool: { must_not: { exists: { field: 'release_id' } } } } # for upgrade compatiblity
              ]
            }
          }
        else
          {
            bool: {
              minimum_should_match: 1,
              should: [
                { term: { release_id: Release.current.id } },
                {
                  bool: {
                    must_not: [{ term: { changeset_release_ids: Release.current.id } }],
                    must: [
                      {
                        bool: {
                          minimum_should_match: 1,
                          should: [
                            { term: { release_id: 'live' } },
                            { bool: { must_not: { exists: { field: 'release_id' } } } } # for upgrade compatiblity
                          ]
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
