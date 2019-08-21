module Workarea
  module Search
    class HelpSearch
      include Query
      include Facets
      include Pagination

      document Search::Help

      def self.available_sorts
        Sort::Collection.new(
          Sort.relevance,
          Sort.newest,
          Sort.name_asc,
          Sort.name_desc
        )
      end

      def sanitized_query
        @sanitized_query ||= QueryString.new(params[:q]).sanitized.presence || '*'
      end

      def current_sort
        self.class.available_sorts.find(params[:sort])
      end

      def query
        {
          query_string: {
            query: sanitized_query,
            fields: %w(name^1.5 facets^0.75 body),
            use_dis_max: true
          }
        }
      end

      def post_filter
        {
          bool: {
            must: facets.map(&:post_filter_clause).reject(&:blank?)
          }
        }
      end

      def facets
        @facets ||= [TermsFacet.new(self, 'category')]
      end

      def sort
        if current_sort.field.present?
          [{ current_sort.field => current_sort.direction }]
        else
          [{ _score: :desc }, { created_at: :desc }]
        end
      end
    end
  end
end
