require 'test_helper'

module Workarea
  class Segment
    module Rules
      class LastOrderTest < TestCase
        def test_qualifies?
          freeze_time
          metrics = Metrics::User.create!(id: 'bcrouse@workarea.com')

          visit = create_visit(email: 'bcrouse@workarea.com')
          refute(LastOrder.new.qualifies?(visit))

          visit = create_visit(email: 'bcrouse@workarea.com')
          refute(LastOrder.new(days: 7).qualifies?(visit))

          metrics.update_attributes!(last_order_at: 8.days.ago)
          visit = create_visit(email: 'bcrouse@workarea.com')
          refute(LastOrder.new(days: 7, within: true).qualifies?(visit))

          metrics.update_attributes!(last_order_at: 7.days.ago)
          visit = create_visit(email: 'bcrouse@workarea.com')
          assert(LastOrder.new(days: 7, within: true).qualifies?(visit))

          metrics.update_attributes!(last_order_at: 6.days.ago)
          visit = create_visit(email: 'bcrouse@workarea.com')
          assert(LastOrder.new(days: 7, within: true).qualifies?(visit))

          metrics.update_attributes!(last_order_at: 8.days.ago)
          visit = create_visit(email: 'bcrouse@workarea.com')
          assert(LastOrder.new(days: 7, within: false).qualifies?(visit))

          metrics.update_attributes!(last_order_at: 7.days.ago)
          visit = create_visit(email: 'bcrouse@workarea.com')
          refute(LastOrder.new(days: 7, within: false).qualifies?(visit))

          metrics.update_attributes!(last_order_at: 6.days.ago)
          visit = create_visit(email: 'bcrouse@workarea.com')
          refute(LastOrder.new(days: 7, within: false).qualifies?(visit))
        end
      end
    end
  end
end
