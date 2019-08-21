require 'test_helper'

module Workarea
  class CleanOrdersTest < TestCase
    def test_perform
      placed = Order.create!(updated_at: 1.year.ago, placed_at: 1.year.ago)
      expired = Order.create!(updated_at: 1.year.ago)
      abandoned = Order.create!(updated_at: 1.year.ago, checkout_started_at: 1.year.ago)
      checkout = Order.create!(checkout_started_at: 5.minutes.ago)
      recent_placed = Order.create!(placed_at: 5.minutes.ago)

      CleanOrders.new.perform

      orders = Order.unscoped.all.to_a
      refute_includes(orders, expired)
      assert_includes(orders, placed)
      refute_includes(orders, abandoned)
      assert_includes(orders, checkout)
      assert_includes(orders, recent_placed)
    end
  end
end
