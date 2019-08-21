require 'test_helper'

module Workarea
  module Catalog
    class VariantTest < Workarea::TestCase
      def test_validates_sku_content
        variant = Variant.new(sku: '12 34')

        refute(variant.valid?)
        refute(variant.errors[:sku].blank?)
      end
    end
  end
end
