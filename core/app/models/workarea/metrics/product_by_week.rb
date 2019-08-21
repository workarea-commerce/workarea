module Workarea
  module Metrics
    class ProductByWeek
      include ByWeek
      include RevenueChange

      field :_id, type: String, default: -> { "#{reporting_on.strftime('%Y%m%d')}-#{product_id}" }
      field :product_id, type: String
      field :views, type: Integer, default: 0
      field :views_percentile, type: Integer
      field :orders, type: Integer, default: 0
      field :units_sold, type: Integer, default: 0
      field :discounted_units_sold, type: Integer, default: 0
      field :merchandise, type: Float, default: 0.0
      field :discounts, type: Float, default: 0.0
      field :tax, type: Float, default: 0.0
      field :average_discount, type: Float, default: 0.0
      field :discount_rate, type: Float, default: 0.0
      field :conversion_rate, type: Float, default: 0.0
      field :units_canceled, type: Integer, default: 0
      field :refund, type: Float, default: 0.0

      index(product_id: 1)
      index(views_percentile: 1, reporting_on: 1, conversion_rate: 1)

      scope :by_product, ->(id) { where(product_id: id) }
      scope :by_views_percentile, ->(range) { where(views_percentile: range) }

      def self.append_last_week!
        append!(ProductForLastWeek.all)
      end
    end
  end
end
