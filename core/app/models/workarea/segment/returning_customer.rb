module Workarea
  class Segment
    class ReturningCustomer < Segment
      include LifeCycle
      self.default_rules = [Rules::Orders.new(minimum: 2)]
    end
  end
end
