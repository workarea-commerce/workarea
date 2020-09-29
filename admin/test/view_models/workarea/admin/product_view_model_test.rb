require 'test_helper'

module Workarea
  module Admin
    class ProductViewModelTest < TestCase
      class FooBar
      end

      setup :set_view_model

      def set_view_model
        @product = Catalog::Product.new
        @view_model = ProductViewModel.new(@product)
      end

      def test_templates_includes_template_options_without_test
        Workarea.config.product_templates = [:foo, :test]
        assert_equal(
          [['Generic', 'generic'], ['Foo', 'foo']],
          @view_model.templates
        )
      end

      def test_variant_details
        @view_model.variants.build(
          sku: 'SKU1',
          name: 'name',
          details: { 'Color' => ['Red'], 'Size' => ['S'] }
        )
        @view_model.variants.build(
          sku: 'SKU2',
          name: 'name',
          details: { 'Color' => ['Black'], 'Size' => ['M'] }
        )
        @view_model.variants.build(
          sku: 'SKU3',
          name: 'name',
          details: { 'Color' => ['White'], 'Size' => ['L'] }
        )

        assert_equal(
          { 'Color' => ['Red', 'Black', 'White'], 'Size' => ['S', 'M', 'L'] },
          @view_model.variant_details
        )
      end

      def test_images_by_option_value
        green_2 = @view_model.images.build(option: 'green', position: 2)
        green_1 = @view_model.images.build(option: 'green', position: 1)

        red_2 = @view_model.images.build(option: 'red', position: 2)
        red_1 = @view_model.images.build(option: 'red', position: 1)

        assert_equal(
          { 'Red' => [red_1, red_2], 'Green' => [green_1, green_2] },
          @view_model.images_by_option
        )
      end

      def test_customization_options
        Workarea.config.customization_types = []
        assert_equal([['None', nil]], @view_model.customization_options)

        Workarea.config.customization_types = [FooBar]
        customizations = @view_model.customization_options
        assert_equal([['None', nil], ['Foo Bar', 'foo_bar']], customizations)
      end

      def test_pricing
        @product.variants.build(sku: 'SKU1')
        @product.variants.build(sku: 'SKU2')

        create_inventory(id: 'SKU1', policy: 'standard', available: 0)
        create_inventory(id: 'SKU2', policy: 'standard', available: 0)

        create_pricing_sku(id: 'SKU1', prices: [{ regular: 4 }])
        create_pricing_sku(id: 'SKU2', prices: [{ regular: 5 }])

        assert_equal(['SKU1', 'SKU2'], @view_model.pricing.skus)
        assert_equal(4.to_m, @view_model.sell_min_price)
        assert(@view_model.show_sell_range?)
      end

      def test_one_price
        @view_model.stubs(:sell_min_price).returns(1.to_m)
        @view_model.stubs(:original_min_price).returns(2.to_m)
        refute(@view_model.one_price?)

        @view_model.stubs(:sell_min_price).returns(1.to_m)
        @view_model.stubs(:original_min_price).returns(1.to_m)
        assert(@view_model.one_price?)

        @view_model.stubs(:sell_min_price).returns(nil)
        @view_model.stubs(:original_min_price).returns(2.to_m)
        refute(@view_model.one_price?)

        @view_model.stubs(:sell_min_price).returns(2.to_m)
        @view_model.stubs(:original_min_price).returns(nil)
        refute(@view_model.one_price?)
      end

      def test_show_sell_range
        @product.variants.build(sku: 'SKU1')
        @product.variants.build(sku: 'SKU2')

        create_pricing_sku(id: 'SKU1', prices: [{ regular: 4 }])
        create_pricing_sku(id: 'SKU2', prices: [{ regular: 5 }])

        create_inventory(id: 'SKU1', policy: 'standard', available: 1)
        create_inventory(id: 'SKU2', policy: 'standard', available: 0)

        assert(@view_model.show_sell_range?)

        @view_model.stubs(:sell_min_price).returns(nil)
        @view_model.stubs(:sell_max_price).returns(1.to_m)
        refute(@view_model.show_sell_range?)

        @view_model.stubs(:sell_min_price).returns(1.to_m)
        @view_model.stubs(:sell_max_price).returns(nil)
        refute(@view_model.show_sell_range?)

        @view_model.stubs(:sell_min_price).returns(1.to_m)
        @view_model.stubs(:sell_max_price).returns(2.to_m)
        assert(@view_model.show_sell_range?)

        @view_model.stubs(:sell_min_price).returns(1.to_m)
        @view_model.stubs(:sell_max_price).returns(1.to_m)
        refute(@view_model.show_sell_range?)
      end

      def test_ignore_inventory
        @product.variants.build(sku: 'SKU1')
        @product.variants.build(sku: 'SKU2')

        create_inventory(id: 'SKU1', policy: 'ignore')
        inventory_two = create_inventory(id: 'SKU2', policy: 'standard')

        refute(@view_model.ignore_inventory?)

        inventory_two.update_attributes!(policy: 'ignore')
        @view_model = ProductViewModel.new(@product)
        assert(@view_model.ignore_inventory?)
      end

      def test_blank_categories
        product = create_product
        view_model = ProductViewModel.new(product)

        assert_nil(view_model.default_category)
        assert_empty(view_model.categories)
      end
    end
  end
end
