module Workarea
  module Storefront
    class ProductTemplates::OptionThumbnailsViewModel < ProductViewModel
      include OptionSetViewModel

      def images_by_option
        @images_by_option ||= model
          .images
          .group_by { |i| i.option.to_s.optionize }
          .with_indifferent_access
          .transform_keys(&:optionize)
      end
    end
  end
end
