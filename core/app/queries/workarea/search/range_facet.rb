module Workarea
  module Search
    class RangeFacet < Facet
      def type
        :range
      end

      def post_filter_clause
        return unless selections.present?

        {
          bool: {
            should: selections
                      .map { |s| RangeParameter.new(s).to_filter }
                      .map { |f| { range: { "numeric.#{system_name}" => f } } }
          }
        }
      end

      def aggregation
        {
          system_name => {
            filter: aggregation_filter,
            aggs: {
              system_name => {
                range: { field: "numeric.#{system_name}", ranges: options }
              }
            }
          }
        }
      end

      def results
        results = search.response.dig(
          'aggregations',
          system_name,
          system_name,
          'buckets'
        )

        results ||= []

        results.reduce({}) do |memo, result|
          if result['doc_count'] > 0
            key = {}
            key[:from] = result['from'] if result['from'].present?
            key[:to] = result['to'] if result['to'].present?
            memo[key] = result['doc_count']
          end

          memo
        end
      end

      def value_to_param(value)
        RangeParameter.to_param(value)
      end
    end
  end
end
