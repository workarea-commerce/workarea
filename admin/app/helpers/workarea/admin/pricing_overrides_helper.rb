module Workarea
  module Admin
    module PricingOverridesHelper
      def allow_pricing_override?
        current_admin&.orders_manager? && current_order.items.any?
      end
    end
  end
end
