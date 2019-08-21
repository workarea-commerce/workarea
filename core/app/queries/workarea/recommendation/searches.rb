module Workarea
  module Recommendation
    class Searches
      def self.find(query)
        id = QueryString.new(query).id
        return [] if id.blank?

        result_ids = SearchPredictor.new.similarities_for(
          id,
          limit: Workarea.config.per_page
        )

        Metrics::SearchByWeek
          .any_in(query_id: result_ids)
          .sort { |a, b| result_ids.index(a.id) <=> result_ids.index(b.id) }
          .map(&:query_string)
          .reject(&:blank?)
      end
    end
  end
end
