require 'test_helper'

module Workarea
  class SaveOrderMetricsTest < Workarea::TestCase
    def test_saves_once_per_order
      order = create_placed_order(email: 'foo@workarea.com')
      refute(order.metrics_saved?)

      2.times { SaveOrderMetrics.perform(order) }
      assert(order.metrics_saved?)
      assert_equal(1, Metrics::User.find('foo@workarea.com').orders)
    end
  end
end
