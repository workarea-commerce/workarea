module Workarea
  module Search
    class TermsFacet < Facet
      def type
        :terms
      end

      def system_name
        @system_name ||= name.systemize
      end

      def post_filter_clause
        return unless selections.present?
        { terms: { "facets.#{system_name}" => selections } }
      end

      def aggregation
        {
          system_name => {
            filter: aggregation_filter,
            aggs: {
              system_name => {
                terms: {
                  field: "facets.#{system_name}",
                  size: facet_size
                }.merge(sorting.to_h)
              }
            }
          }
        }
      end

      def facet_size
        Workarea.config.search_facet_result_sizes[system_name.to_sym] || Workarea.config.default_search_facet_result_sizes
      end

      def sorting
        FacetSorting.new(system_name.to_sym)
      end

      def results
        @results ||=
          begin
            results = Array.wrap(
              search.response.dig('aggregations', system_name, system_name, 'buckets')
            )

            results = results.each_with_object({}) do |result, memo|
              next unless result['doc_count'].positive?
              memo[result['key']] = result['doc_count']
            end

            sorting.apply(results, facet_size)
          end
      end

      def value_to_param(value)
        value.to_s
      end
    end
  end
end
