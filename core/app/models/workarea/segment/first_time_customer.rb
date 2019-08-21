module Workarea
  class Segment
    class FirstTimeCustomer < Segment
      include LifeCycle
      self.default_rules = [Rules::Orders.new(minimum: 1, maximum: 1)]
    end
  end
end
