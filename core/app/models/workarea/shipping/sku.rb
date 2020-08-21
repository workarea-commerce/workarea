module Workarea
  class Shipping
    class Sku
      include ApplicationDocument

      field :_id, type: String
      field :weight, type: Float, default: 0

      # @!attribute dimensions
      #   @return [Array] Height x Width x Length
      #
      field :dimensions, type: Array, default: []

      # This is for compatibility with the admin, all models must implement this
      #
      # @return [String]
      #
      def name
        I18n.t('workarea.shipping_sku.name', id: id)
      end

      def height
        dimensions.first
      end

      def height=(new_height)
        dimensions[0] = new_height&.to_f
      end

      def width
        dimensions.second
      end

      def width=(new_width)
        dimensions[1] = new_width&.to_f
      end

      def length
        dimensions.third
      end

      def length=(new_length)
        dimensions[2] = new_length&.to_f
      end

      def length_units
        Workarea.config.shipping_options[:units] == :imperial ? :inches : :centimeters
      end

      def weight_units
        Workarea.config.shipping_options[:units] == :imperial ? :ounces : :grams
      end
    end
  end
end
