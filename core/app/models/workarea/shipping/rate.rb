# frozen_string_literal: true
module Workarea
  class Shipping
    class Rate
      include ApplicationDocument

      field :price, type: Money, default: 0
      field :tier_min, type: Money
      field :tier_max, type: Money

      embedded_in :service, class_name: 'Workarea::Shipping::Service', touch: false

      validates :price, presence: true

      def tiered?
        !tier_min.nil? || !tier_max.nil?
      end
    end
  end
end
