require 'test_helper'

module Workarea
  class IndexPaymentTransactionsTest < TestCase
    include SearchIndexing

    def get_current_index(order)
      Search::Admin::Order.search(
        Search::Admin::Order.new(order).id
      ).dig('hits', 'hits', 0, '_source')
    end

    def test_indexing
      Sidekiq::Callbacks.enable(IndexAdminSearch, IndexPaymentTransactions) do
        order = create_placed_order
        payment = Payment.find(order.id)

        assert_equal(
          'authorized',
          get_current_index(order)['facets']['payment_status']
        )

        payment.credit_card.build_transaction(
          amount: order.total_price,
          success: true,
          action: 'capture'
        ).save!

        assert_equal(
          'captured',
          get_current_index(order)['facets']['payment_status']
        )
      end
    end

    def test_not_indexing_unplaced_orders
      order = create_order
      IndexPaymentTransactions.new.perform(order.id)
      assert_equal(0, Search::Admin::Order.count)
    end
  end
end
