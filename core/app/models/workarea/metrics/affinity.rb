module Workarea
  module Metrics
    class Affinity
      include ApplicationDocument

      field :product_ids, type: Array, default: []
      field :category_ids, type: Array, default: []
      field :search_ids, type: Array, default: []

      embedded_in :user, class_name: 'Workarea::Metrics::User'

      def recent_product_ids(max: Workarea.config.affinity_default_recent_size)
        product_ids.reverse.take(max)
      end

      def recent_category_ids(max: Workarea.config.affinity_default_recent_size)
        category_ids.reverse.take(max)
      end

      def recent_search_ids(max: Workarea.config.affinity_default_recent_size)
        search_ids.reverse.take(max)
      end
    end
  end
end
