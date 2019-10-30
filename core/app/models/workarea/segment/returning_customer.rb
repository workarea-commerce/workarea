module Workarea
  class Segment
    class ReturningCustomer < Segment
      include LifeCycle

      self.default_rules = [
        Rules::Orders.new(
          minimum: 2,
          maximum: Workarea.config.loyal_customers_min_orders - 1
        )
      ]
    end
  end
end
