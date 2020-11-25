module Workarea
  class IndexCategorization
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: { Catalog::Category => [:save, :save_release_changes] },
      lock: :until_executing
    )

    def self.perform(category)
      Search::Storefront::CategoryQuery.new(category).update
    end

    def perform(id)
      category = Catalog::Category.find(id)
      self.class.perform(category)
    end
  end
end
