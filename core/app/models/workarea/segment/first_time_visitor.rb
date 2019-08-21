module Workarea
  class Segment
    class FirstTimeVisitor < Segment
      include LifeCycle

      self.default_rules = [
        Rules::Sessions.new(minimum: 0, maximum: 1),
        Rules::Orders.new(maximum: 0)
      ]
    end
  end
end
