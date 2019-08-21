module Workarea
  class Segment
    class LoyalCustomer < Segment
      include LifeCycle

      self.default_rules = [
        Rules::Orders.new(minimum: Workarea.config.loyal_customers_min_orders),
        Rules::LastOrder.new(days: Workarea.config.loyal_customers_last_order_days_ago)
      ]
    end
  end
end
