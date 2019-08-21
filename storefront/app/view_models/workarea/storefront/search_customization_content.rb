module Workarea
  module Storefront
    module SearchCustomizationContent

      def customization
        @customization ||= SearchCustomizationViewModel.new(model.customization)
      end

      def customization_content_blocks_for(area)
        return [] unless customization.persisted?
        customization.content_blocks_for(area)
      end
    end
  end
end
