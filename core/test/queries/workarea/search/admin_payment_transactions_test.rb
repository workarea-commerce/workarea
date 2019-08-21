require 'test_helper'

module Workarea
  module Search
    class AdminPaymentTransactionsTest < IntegrationTest
      def test_searching_by_order
        create_placed_order(id: 'foo')
        search = AdminPaymentTransactions.new(q: 'foo')
        assert_equal(1, search.total)
      end
    end
  end
end
