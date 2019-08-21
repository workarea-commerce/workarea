require 'test_helper'

module Workarea
  class Segment
    module Rules
      class OrdersTest < TestCase
        def test_qualifies?
          metrics = Metrics::User.create!(id: 'bcrouse@workarea.com')

          visit = create_visit(email: 'bcrouse@workarea.com')
          refute(Orders.new.qualifies?(visit))

          visit = create_visit(email: 'bcrouse@workarea.com')
          refute(Orders.new(minimum: 1).qualifies?(visit))

          metrics.update_attributes!(orders: 0)
          visit = create_visit(email: 'bcrouse@workarea.com')
          refute(Orders.new(minimum: 1).qualifies?(visit))

          metrics.update_attributes!(orders: 1)
          visit = create_visit(email: 'bcrouse@workarea.com')
          assert(Orders.new(minimum: 1).qualifies?(visit))

          metrics.update_attributes!(orders: 2)
          visit = create_visit(email: 'bcrouse@workarea.com')
          assert(Orders.new(minimum: 1).qualifies?(visit))

          metrics.update_attributes!(orders: 0)
          visit = create_visit(email: 'bcrouse@workarea.com')
          assert(Orders.new(maximum: 2).qualifies?(visit))

          metrics.update_attributes!(orders: 1)
          visit = create_visit(email: 'bcrouse@workarea.com')
          assert(Orders.new(maximum: 2).qualifies?(visit))

          metrics.update_attributes!(orders: 2)
          visit = create_visit(email: 'bcrouse@workarea.com')
          assert(Orders.new(maximum: 2).qualifies?(visit))

          metrics.update_attributes!(orders: 3)
          visit = create_visit(email: 'bcrouse@workarea.com')
          refute(Orders.new(maximum: 2).qualifies?(visit))

          metrics.update_attributes!(orders: 3)
          visit = create_visit(email: 'bcrouse@workarea.com')
          refute(Orders.new(minimum: 1, maximum: 2).qualifies?(visit))

          metrics.update_attributes!(orders: 1)
          visit = create_visit(email: 'bcrouse@workarea.com')
          assert(Orders.new(minimum: 1, maximum: 2).qualifies?(visit))

          metrics.update_attributes!(orders: 2)
          visit = create_visit(email: 'bcrouse@workarea.com')
          assert(Orders.new(minimum: 1, maximum: 2).qualifies?(visit))
        end
      end
    end
  end
end
