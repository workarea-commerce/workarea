module Workarea
  # This mixin includes 2 responsibilities:
  # *   Provide logic to aggregate discount IDs from price adjustments
  # *   Persist to the database for querying later
  #
  module DiscountIds
    extend ActiveSupport::Concern

    included do
      field :discount_ids, type: Array, default: []
      before_save :set_discount_ids
      index({ discount_ids: 1 })
    end

    module ClassMethods
      def discount_ids
        distinct(:discount_ids)
      end
    end

    def discount_ids
      price_adjustments
        .map { |pa| pa.data['discount_id'] }
        .compact
        .uniq
    end

    private

    def set_discount_ids
      self.discount_ids = discount_ids
    end
  end
end
