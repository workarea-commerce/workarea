module Workarea
  class IndexPaymentTransactions
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: {
        Payment::Transaction => :save,
        with: -> { [payment_id] },
        ignore_if: -> { !success? }
      },
      lock: :until_executing
    )

    def perform(order_id)
      order = Order.find(order_id) rescue nil
      return unless order.present?

      search_model = Search::Admin::Order.new(order)
      search_model.save if search_model.should_be_indexed?
    end
  end
end
