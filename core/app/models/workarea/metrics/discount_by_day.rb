module Workarea
  module Metrics
    class DiscountByDay
      include ByDay

      field :discount_id, type: String
      field :orders, type: Integer, default: 0
      field :merchandise, type: Float, default: 0.0
      field :discounts, type: Float, default: 0.0
      field :revenue, type: Float, default: 0.0

      index(reporting_on: 1, orders: 1)
      index(discount_id: 1, reporting_on: 1)
      scope :by_discount, ->(id) { where(discount_id: id) }
    end
  end
end
