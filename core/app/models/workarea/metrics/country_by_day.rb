module Workarea
  module Metrics
    class CountryByDay
      include ByDay

      field :country, type: Country
      field :orders, type: Integer, default: 0
      field :units_sold, type: Integer, default: 0
      field :discounted_units_sold, type: Integer, default: 0
      field :merchandise, type: Float, default: 0.0
      field :shipping, type: Float, default: 0.0
      field :discounts, type: Float, default: 0.0
      field :tax, type: Float, default: 0.0
      field :revenue, type: Float, default: 0.0
      field :cancellations, type: Integer, default: 0
      field :units_canceled, type: Integer, default: 0
      field :refund, type: Float, default: 0.0

      index(reporting_on: 1, orders: 1)
      index(reporting_on: 1, units_sold: 1)
      index(reporting_on: 1, units_canceled: 1)
    end
  end
end
