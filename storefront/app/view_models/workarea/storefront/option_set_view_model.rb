module Workarea
  module Storefront
    # Mixed into ProductViewModels for options-selection-based templates.
    module OptionSetViewModel
      extend ActiveSupport::Concern

      included do
        delegate :options_for_selection, :currently_selected_options,
          to: :option_set
      end

      def current_sku
        options[:sku].presence || option_set.current_sku
      end

      def pricing
        return super unless options[:pricing].blank? && option_set.current_sku.present?
        @pricing ||= Pricing::Collection.new(option_set.current_sku)
      end

      def images
        @images_for_options_set ||= if images_matching_options.any?
          images_matching_options
        else
          images_matching_primary(super.primary)
        end
      end

      private

      def images_matching_options
        @images_matching_options ||= begin
          images = model.images.select do |image|
            current_values = currently_selected_options.values.flatten.map(&:optionize)
            image.option.to_s.optionize.in?(current_values)
          end

          ProductViewModel::ImageCollection.new(model, options, images)
        end
      end

      def images_matching_primary(primary_image)
        images = model.images.select do |image|
          image.option.to_s.optionize == primary_image.option.to_s.optionize
        end

        ProductViewModel::ImageCollection.new(model, options, images)
      end

      def option_set
        @option_set ||= if options[:sku].present?
          ProductViewModel::OptionSet.from_sku(self, options[:sku], options)
        else
          ProductViewModel::OptionSet.new(self, options)
        end
      end
    end
  end
end
