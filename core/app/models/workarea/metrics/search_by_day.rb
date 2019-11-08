module Workarea
  module Metrics
    class SearchByDay
      include ByDay

      field :query_id, type: String
      field :query_string, type: String
      field :searches, type: Integer, default: 0
      field :total_results, type: Integer, default: 0
      field :orders, type: Integer, default: 0
      field :units_sold, type: Integer, default: 0
      field :discounted_units_sold, type: Integer, default: 0
      field :merchandise, type: Float, default: 0.0
      field :shipping, type: Float, default: 0.0
      field :discounts, type: Float, default: 0.0
      field :tax, type: Float, default: 0.0
      field :revenue, type: Float, default: 0.0

      index(reporting_on: 1, total_results: 1)
      index(query_id: 1)

      scope :by_query_id, ->(id) { where(query_id: id) }

      def self.save_search(query_string, total_results, at: Time.current)
        query_string = QueryString.new(query_string)
        return if query_string.id.blank? || query_string.short? || total_results.blank?

        inc(
          key: { query_id: query_string.id },
          set: { total_results: total_results.to_i, query_string: query_string.pretty },
          at: at,
          searches: 1
        )
      end
    end
  end
end
