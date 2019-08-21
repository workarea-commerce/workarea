module Workarea
  module Metrics
    class SearchByWeek
      include ByWeek
      include RevenueChange

      field :_id, type: String, default: -> { "#{reporting_on.strftime('%Y%m%d')}-#{query_id}" }
      field :query_id, type: String
      field :total_results, type: Integer
      field :query_string, type: String
      field :searches, type: Integer, default: 0
      field :searches_percentile, type: Integer
      field :orders, type: Integer, default: 0
      field :units_sold, type: Integer, default: 0
      field :discounted_units_sold, type: Integer, default: 0
      field :merchandise, type: Float, default: 0.0
      field :discounts, type: Float, default: 0.0
      field :tax, type: Float, default: 0.0
      field :average_discount, type: Float, default: 0.0
      field :discount_rate, type: Float, default: 0.0
      field :conversion_rate, type: Float, default: 0.0

      index(query_id: 1)
      index(searches_percentile: 1, reporting_on: 1, conversion_rate: 1)

      scope :by_query, ->(id) { where(query_id: id) }
      scope :by_searches_percentile, ->(range) { where(searches_percentile: range) }
      scope :has_results, -> { where(:total_results.gt => 0) }
      scope :most_searched, -> { desc(:searches) }

      def self.append_last_week!
        append!(SearchForLastWeek.all)
      end
    end
  end
end
