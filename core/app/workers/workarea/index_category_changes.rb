module Workarea
  class IndexCategoryChanges
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: { Catalog::Category => [:save, :save_release_changes], with: -> { [changes] } },
      ignore_if: -> { changes['product_ids'].blank? },
      lock: :until_executing
    )

    def perform(changes)
      return unless changes['product_ids'].present?

      ids = require_index_ids(*changes['product_ids'])

      if ids.size > max_count
        ids.each { |id| IndexProduct.perform_async(id) }
      else
        Catalog::Product.in(id: ids).each do |product|
          begin
            IndexProduct.perform(product)
          rescue
            IndexProduct.perform_async(product.id)
          end
        end
      end
    end

    def require_index_ids(previous_ids, new_ids)
      previous_ids = Array.wrap(previous_ids)
      new_ids = Array.wrap(new_ids)

      new_ids.reject do |id|
        previous_ids.index(id).present? &&
          previous_ids.index(id) == new_ids.index(id)
      end + (previous_ids - new_ids)
    end

    def max_count
      Workarea.config.category_inline_index_product_max_count
    end
  end
end
