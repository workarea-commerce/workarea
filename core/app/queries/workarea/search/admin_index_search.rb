module Workarea
  module Search
    module AdminIndexSearch
      extend ActiveSupport::Concern

      def sanitized_query
        @sanitized_query ||= QueryString.new(params[:q]).sanitized
      end

      def autocomplete?
        !!params[:autocomplete]
      end

      def fields
        %w(search_text jump_to_text jump_to_search_text)
      end

      def query
        filter_clauses = [
          filters.map(&:query_clause).reject(&:blank?),
          exclude_filter_clause,
          jump_to_navigation_filter_clause
        ].flatten

        if sanitized_query.blank?
          { bool: { must: filter_clauses } }
        elsif autocomplete?
          {
            bool: {
              must: filter_clauses + [
                {
                  match_phrase_prefix: {
                    jump_to_search_text: {
                      query: sanitized_query,
                      max_expansions: 10
                    }
                  }
                }
              ]
            }
          }
        else
          {
            bool: {
              must: filter_clauses + [
                {
                  bool: {
                    should: [
                      {
                        query_string: {
                          query: sanitized_query,
                          fields: fields,
                          use_dis_max: true
                        }
                      },
                      {
                        match: {
                          keywords: {
                            query: params[:q].downcase,
                            type: 'phrase',
                            boost: 999
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

      def aggregations
        results = facets.map(&:aggregation).reduce(&:merge)
        return results unless results['type'].present?

        agg = if results['type'][:terms].present?
                results['type']
              elsif results['type'][:aggs].present? &&
                      results['type'][:aggs]['type'].present?
                results['type'][:aggs]['type']
              end

        agg[:terms][:size] = 50
        agg[:terms][:order] = { _term: 'asc' }

        results
      end

      def post_filter
        {
          bool: {
            must: facets.map(&:post_filter_clause).reject(&:blank?)
          }
        }
      end

      def jump_to_navigation_filter_clause
        { exists: { field: :jump_to_param } }
      end

      def exclude_filter_clause
        return {} unless params[:exclude_ids].present?
        { bool: { must_not: { terms: { _id: Array(params[:exclude_ids]) } } } }
      end

      def filters
        @filters ||= [
          DateFilter.new(self, 'created_at', :gte),
          DateFilter.new(self, 'created_at', :lte),
          DateFilter.new(self, 'updated_at', :gte),
          DateFilter.new(self, 'updated_at', :lte)
        ]
      end

      def facets
        @facets ||= [
          TermsFacet.new(self, 'type'),
          TermsFacet.new(self, 'status'),
          TermsFacet.new(self, 'tags'),
          TermsFacet.new(self, 'upcoming_changes'),
          TermsFacet.new(self, 'active_by_segment')
        ]
      end
    end
  end
end
