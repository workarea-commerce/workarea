module Workarea
  class CleanInventoryTransactions
    include Sidekiq::Worker

    def perform(*args)
      Inventory::Transaction.expired.delete_all
    end
  end
end
