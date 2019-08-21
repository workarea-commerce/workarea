module Workarea
  module Metrics
    class TrafficReferrerByDay
      include ByDay

      field :medium, type: String
      field :source, type: String
      field :orders, type: Integer, default: 0
      field :units_sold, type: Integer, default: 0
      field :discounted_units_sold, type: Integer, default: 0
      field :merchandise, type: Float, default: 0.0
      field :shipping, type: Float, default: 0.0
      field :discounts, type: Float, default: 0.0
      field :tax, type: Float, default: 0.0
      field :revenue, type: Float, default: 0.0

      index(reporting_on: 1, orders: 1)
    end
  end
end
