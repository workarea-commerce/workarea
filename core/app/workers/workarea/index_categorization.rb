module Workarea
  class IndexCategorization
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: { Catalog::Category => :save },
      lock: :until_executing
    )

    def self.perform(category)
      Search::Storefront::Product.delete_category(category.id)

      return unless category.product_rules.present?

      Search::Storefront::Product.add_category(category)
    end

    def perform(id)
      category = Catalog::Category.find(id)
      self.class.perform(category)
    end
  end
end
