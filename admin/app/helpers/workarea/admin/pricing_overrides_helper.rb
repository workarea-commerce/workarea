module Workarea
  module Admin
    module PricingOverridesHelper
      def allow_pricing_override?
        current_admin&.orders_management_access? && current_order.items.any?
      end
    end
  end
end
