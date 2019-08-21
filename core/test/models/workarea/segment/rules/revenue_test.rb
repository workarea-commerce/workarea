require 'test_helper'

module Workarea
  class Segment
    module Rules
      class RevenueTest < TestCase
        def test_qualifies?
          metrics = Metrics::User.create!(id: 'bcrouse@workarea.com')

          visit = create_visit(email: 'bcrouse@workarea.com')
          refute(Revenue.new.qualifies?(visit))

          visit = create_visit(email: 'bcrouse@workarea.com')
          refute(Revenue.new(minimum: 1).qualifies?(visit))

          metrics.update_attributes!(revenue: 0)
          visit = create_visit(email: 'bcrouse@workarea.com')
          refute(Revenue.new(minimum: 1).qualifies?(visit))

          metrics.update_attributes!(revenue: 1)
          visit = create_visit(email: 'bcrouse@workarea.com')
          assert(Revenue.new(minimum: 1).qualifies?(visit))

          metrics.update_attributes!(revenue: 2)
          visit = create_visit(email: 'bcrouse@workarea.com')
          assert(Revenue.new(minimum: 1).qualifies?(visit))

          metrics.update_attributes!(revenue: 0)
          visit = create_visit(email: 'bcrouse@workarea.com')
          assert(Revenue.new(maximum: 2).qualifies?(visit))

          metrics.update_attributes!(revenue: 1)
          visit = create_visit(email: 'bcrouse@workarea.com')
          assert(Revenue.new(maximum: 2).qualifies?(visit))

          metrics.update_attributes!(revenue: 2)
          visit = create_visit(email: 'bcrouse@workarea.com')
          assert(Revenue.new(maximum: 2).qualifies?(visit))

          metrics.update_attributes!(revenue: 3)
          visit = create_visit(email: 'bcrouse@workarea.com')
          refute(Revenue.new(maximum: 2).qualifies?(visit))

          metrics.update_attributes!(revenue: 3)
          visit = create_visit(email: 'bcrouse@workarea.com')
          refute(Revenue.new(minimum: 1, maximum: 2).qualifies?(visit))

          metrics.update_attributes!(revenue: 1)
          visit = create_visit(email: 'bcrouse@workarea.com')
          assert(Revenue.new(minimum: 1, maximum: 2).qualifies?(visit))

          metrics.update_attributes!(revenue: 2)
          visit = create_visit(email: 'bcrouse@workarea.com')
          assert(Revenue.new(minimum: 1, maximum: 2).qualifies?(visit))
        end
      end
    end
  end
end
