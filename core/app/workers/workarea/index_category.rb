module Workarea
  class IndexCategory
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: { Catalog::Category => [:save, :destroy] },
      lock: :until_executing
    )

    def perform(id)
      category = Catalog::Category.find(id)
      Search::Storefront::Category.new(category).save
    rescue Mongoid::Errors::DocumentNotFound
      Search::Storefront::Category.new(
        Catalog::Category.new(id: id)
      ).destroy
    end
  end
end
