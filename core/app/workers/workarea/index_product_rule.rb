module Workarea
  class IndexProductRule
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: {
        ProductRule => %i[save save_release_changes destroy],
        ignore_if: -> {
          product_list.class.name != 'Workarea::Catalog::Category'
        },
        with: -> { [product_list.id] }
      },
      unique: :until_executing
    )

    def perform(id)
      product_list = Catalog::Category.find(id)
      IndexCategorization.perform(product_list)
    end
  end
end
