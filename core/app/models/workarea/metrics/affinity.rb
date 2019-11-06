module Workarea
  module Metrics
    class Affinity
      include ApplicationDocument

      field :product_ids, type: Array, default: []
      field :category_ids, type: Array, default: []
      field :search_ids, type: Array, default: []

      embedded_in :user, class_name: 'Workarea::Metrics::User'

      def recent_product_ids(max: Workarea.config.affinity_default_recent_size, unique: false)
        recent_ids(product_ids, max: max, unique: unique)
      end

      def recent_category_ids(max: Workarea.config.affinity_default_recent_size, unique: false)
        recent_ids(category_ids, max: max, unique: unique)
      end

      def recent_search_ids(max: Workarea.config.affinity_default_recent_size, unique: false)
        recent_ids(search_ids, max: max, unique: unique)
      end

      private

      def recent_ids(ids, max:, unique:)
        ids = ids.reverse
        ids.uniq! if unique
        ids.take(max)
      end
    end
  end
end
