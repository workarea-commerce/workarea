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

      def height
        dimensions.first
      end

      def width
        dimensions.second
      end

      def length
        dimensions.third
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
