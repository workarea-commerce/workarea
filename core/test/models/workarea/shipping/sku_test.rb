require 'test_helper'

module Workarea
  class Shipping
    class SkuTest < Workarea::TestCase
      def test_length_units
        sku = create_shipping_sku

        Workarea.config.shipping_options = { units: :imperial }
        assert_equal(:inches, sku.length_units)

        Workarea.config.shipping_options = { units: :metric }
        assert_equal(:centimeters, sku.length_units)
      end

      def test_weight_units
        sku = create_shipping_sku

        Workarea.config.shipping_options = { units: :imperial }
        assert_equal(:ounces, sku.weight_units)

        Workarea.config.shipping_options = { units: :metric }
        assert_equal(:grams, sku.weight_units)
      end
    end
  end
end
