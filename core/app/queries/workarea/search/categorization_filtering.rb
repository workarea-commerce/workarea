module Workarea
  module Search
    # TODO: v4 - use ProductRulesFiltering and refactor category_ids to
    # separate module.
    module CategorizationFiltering
      def category_ids
        Array(params[:category_ids]).map(&:to_s)
      end

      def category_filters
        @category_filters ||= ProductRules.new(params[:rules]).to_a
      end

      def category_query_clauses
        return [] if category_filters.blank? && category_ids.blank?

        results = []

        if category_filters.blank?
          results << { terms: { 'facets.category_id' => category_ids } }
        elsif category_ids.blank?
          results.push(*category_filters)
        else
          results.push(
            bool: {
              should: [
                { terms: { 'facets.category_id' => category_ids } },
                { bool: { must: category_filters } }
              ]
            }
          )
        end

        results
      end
    end
  end
end
