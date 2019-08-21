module Workarea
  module Recommendation
    class Settings
      include ApplicationDocument

      # _id will match the product ID
      field :_id, type: String, default: -> { SecureRandom.hex(5).upcase }
      field :sources, type: Array, default: Workarea.config.product_based_recommendation_default_sources
      field :product_ids, type: Array, default: []
      list_field :product_ids

      validates :sources, presence: true
      before_validation :ensure_sources

      private

      def ensure_sources
        if sources.blank?
          self.sources = Workarea.config.product_based_recommendation_default_sources
        end
      end
    end
  end
end
