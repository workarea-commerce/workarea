module Workarea
  module Storefront
    module CheckPricingOverride
      def check_pricing_override
        return if current_admin.present?

        override = Pricing::Override.find_or_initialize_by(id: current_order.id)

        if override.has_adjustments?
          flash[:error] = t('workarea.storefront.flash_messages.order_custom_pricing')
          redirect_to cart_path
          return false
        end
      end
    end
  end
end
