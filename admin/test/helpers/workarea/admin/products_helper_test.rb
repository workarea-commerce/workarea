require 'test_helper'

module Workarea
  module Admin
    class ProductsHelperTest < ViewTest
      setup :create_products

      def create_products
        inactive = create_product(active: false)
        @inactive = ProductViewModel.wrap(inactive)

        backordered = create_product(variants: [{ sku: 'BACKORDERED' }])
        @backordered = ProductViewModel.wrap(backordered)

        out_of_stock = create_product(variants: [{ sku: 'OUTOFSTOCK' }])
        @out_of_stock = ProductViewModel.wrap(out_of_stock)

        low_inventory = create_product(variants: [{ sku: 'LOWINVENTORY' }])
        @low_inventory = ProductViewModel.wrap(low_inventory)

        displayable = create_product(variants: [{ sku: 'DISPLAYABLE' }])
        @displayable = ProductViewModel.wrap(displayable)

        create_inventory(
          id: 'BACKORDERED',
          policy: 'allow_backorder',
          backordered: 1,
          available: 0
        )

        create_inventory(
          id: 'OUTOFSTOCK',
          policy: 'standard',
          backordered: 0,
          available: 0
        )

        create_inventory(
          id: 'LOWINVENTORY',
          available: Workarea.config.low_inventory_threshold - 1
        )

        create_inventory(
          id: 'DISPLAYABLE',
          policy: 'displayable_when_out_of_stock',
          backordered: 0,
          available: 0
        )
      end

      def test_summary_inventory_status_css_classes
        result = summary_inventory_status_css_classes(@inactive)
        assert_includes(result, 'product-summary--inactive')
        assert_includes(result, 'product-summary--status-issue')

        result = summary_inventory_status_css_classes(@backordered)
        assert_includes(result, 'product-summary--backordered')
        assert_includes(result, 'product-summary--status-issue')

        result = summary_inventory_status_css_classes(@out_of_stock)
        assert_includes(result, 'product-summary--out-of-stock')
        assert_includes(result, 'product-summary--status-issue')

        result = summary_inventory_status_css_classes(@low_inventory)
        assert_includes(result, 'product-summary--low-inventory')
        assert_includes(result, 'product-summary--status-issue')

        result = summary_inventory_status_css_classes(@displayable)
        assert(result.empty?)
      end
    end
  end
end
