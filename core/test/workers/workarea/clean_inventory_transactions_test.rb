require 'test_helper'

module Workarea
  class CleanInventoryTransactionsTest < TestCase
    def test_perform
      expired = Inventory::Transaction.create!(updated_at: 1.year.ago, captured: false)
      captured = Inventory::Transaction.create!(updated_at: 1.year.ago).tap(&:purchase)
      not_expired = Inventory::Transaction.create!(updated_at: 1.month.ago)

      CleanInventoryTransactions.new.perform

      orders = Inventory::Transaction.all.to_a

      refute_includes(orders, expired)
      assert_includes(orders, captured)
      assert_includes(orders, not_expired)
    end
  end
end
