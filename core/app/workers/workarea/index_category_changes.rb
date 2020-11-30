module Workarea
  class IndexCategoryChanges
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: {
        Catalog::Category => [:save, :save_release_changes],
        with: -> { [changes, Release.current.present?] }
      },
      ignore_if: -> { changes['product_ids'].blank? },
      lock: :until_executing
    )

    def perform(changes, for_release = false)
      return unless changes['product_ids'].present?

      ids = if for_release
        # This is a shortcut because if you're resorting products within a release,
        # the `changes` hash doesn't reflect the repositioning within the release,
        # only the difference between what's live and what's in the release.
        #
        # Reindexing all of them is a shortcut to having to manually build a diff
        # between the changesets in the possible affected releases.
        changes['product_ids'].flatten.uniq
      else
        require_index_ids(*changes['product_ids'])
      end

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
