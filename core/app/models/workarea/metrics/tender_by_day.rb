module Workarea
  module Metrics
    class TenderByDay
      include ByDay

      field :tender, type: String
      field :orders, type: Integer, default: 0
      field :revenue, type: Float, default: 0.0
    end
  end
end
