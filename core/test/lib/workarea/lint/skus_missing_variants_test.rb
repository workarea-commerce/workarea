require 'test_helper'
require 'workarea/lint'

module Workarea
  class Lint
    load_lints

    class SkusMissingVariantsTest < TestCase
      def test_errors_for_each_inventory_sku_missing_a_variant
        Inventory::Sku.create!(id: '123')
        Inventory::Sku.create!(id: '456')

        Catalog::Product.create!(name: 'Foo', variants: [{ sku: '123' }])

        lint = SkusMissingVariants.new
        lint.run

        assert_equal(1, lint.errors)
      end

      def test_errors_for_each_pricing_sku_missing_a_variant
        Pricing::Sku.create!(id: '123')
        Pricing::Sku.create!(id: '456')

        Catalog::Product.create!(name: 'Foo', variants: [{ sku: '123' }])

        lint = SkusMissingVariants.new
        lint.run

        assert_equal(1, lint.errors)
      end
    end
  end
end
