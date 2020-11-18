require 'test_helper'

module Workarea
  module Storefront
    class ProductViewModelTest < TestCase
      setup :set_product

      def set_product
        @product = create_product(name: 'test')
      end

      def test_wrap_finds_the_view_model_based_on_template
        @product.template = 'option_selects'

        view_model = ProductViewModel.wrap(@product, one: '1')
        assert_instance_of(ProductTemplates::OptionSelectsViewModel, view_model)
        assert_equal('1', view_model.options[:one])

        Workarea.with_config do |config|
          config.product_templates << :no_view_model
          @product.template = 'no_view_model'
          view_model = ProductViewModel.wrap(@product, one: '1')

          assert_kind_of(ProductViewModel, view_model)
        end
      end

      def test_cache_key
        cached_product = Catalog::Product.instantiate(@product.as_document)

        view_model = ProductViewModel.new(cached_product)
        assert_match(/#{@product.id}/, view_model.cache_key)
        assert_match(/#{@product.updated_at.utc.to_s(:nsec)}/, view_model.cache_key)

        view_model = ProductViewModel.new(cached_product, via: '1/2/3')
        assert_match(/1\/2\/3/, view_model.cache_key)

        @product.variants.build(sku: 'SKU')
        view_model = ProductViewModel.new(cached_product)
        refute_match(/SKU/, view_model.cache_key)

        view_model = ProductViewModel.new(cached_product, sku: 'SKU')
        assert_match(/SKU/, view_model.cache_key)
      end

      def test_cache_key_with_options
        variant = @product.variants.build(sku: 'SKU', details: { 'Color' => 'blue' })
        cached_product = Catalog::Product.instantiate(@product.as_document)
        options = { action: 'show', sku: variant.sku }.merge(variant.details)
        view_model = ProductViewModel.new(cached_product, options)

        assert_includes(view_model.cache_key, variant.fetch_detail(:color))
        refute_includes(view_model.cache_key, options[:action])
      end

      def test_variants_only_includes_variants_with_displayable_inventory
        view_model = ProductViewModel.new(@product)
        variant = @product.variants.build(sku: 'INVTEST')
        create_inventory(id: 'INVTEST', policy: 'standard', available: 0)

        refute_includes(view_model.variants, variant)
      end

      def test_current_sku
        @product.variants.build(sku: 'test')

        view_model = ProductViewModel.new(@product, sku: nil)
        assert_nil(view_model.current_sku)

        view_model = ProductViewModel.new(@product, sku: 'test')
        assert_equal('test', view_model.current_sku)

        view_model = ProductViewModel.new(@product, sku: '1234')
        assert_equal('1234', view_model.current_sku)
      end

      def test_sku_options_uses_name
        variant = @product.variants.build(sku: 'SKU', name: 'name', details: { 'foo' => 'bar' })
        view_model = ProductViewModel.new(@product, sku: '1234')

        assert_includes(view_model.sku_options, ["name", "SKU", data: { sku_option_details: variant.details.to_json }])
      end

      def test_sku_options_uses_details
        variant = @product.variants.build(sku: 'SKU', name: 'SKU', details: { 'foo' => 'bar' })
        view_model = ProductViewModel.new(@product, sku: '1234')

        assert_includes(view_model.sku_options, ["SKU - Foo: bar", "SKU", data: { sku_option_details: variant.details.to_json }])
      end

      def test_sku_options_uses_comma_separates_arrays_in_details
        variant = @product.variants.build(sku: 'SKU', name: 'SKU', details: { 'foo' => ['bar', 'baz'] })
        view_model = ProductViewModel.new(@product, sku: '1234')

        assert_includes(view_model.sku_options, ["SKU - Foo: bar, baz", "SKU", data: { sku_option_details: variant.details.to_json }])
      end

      def test_breadcrumbs_uses_the_default_category_if_no_via_param
        category = create_category(product_ids: [@product.id])
        result = ProductViewModel.new(@product).breadcrumbs.navigable
        assert_equal(category, result)
      end

      def test_breadcrumbs_adds_the_product_name_as_the_last_breadcrumb
        view_model = ProductViewModel.new(@product)
        result = view_model.breadcrumbs.last
        assert_equal(@product.name, result.name)
      end

      def test_one_price
        @product.variants = [{ sku: 'SKU1' }]
        pricing = create_pricing_sku(id: 'SKU1', msrp: 5)

        pricing.set(prices: [])
        refute(ProductViewModel.new(@product).one_price?)

        pricing.prices = [{ regular: 3 }]
        refute(ProductViewModel.new(@product).one_price?)

        pricing.update_attributes!(msrp: 3)
        assert(ProductViewModel.new(@product).one_price?)
      end

      def test_show_sell_range
        @product.variants = [{ sku: 'SKU1' }, { sku: 'SKU2' }]
        pricing_one = create_pricing_sku(id: 'SKU1')
        pricing_two = create_pricing_sku(id: 'SKU2')

        pricing_one.set(prices: [])
        pricing_two.set(prices: [])
        refute(ProductViewModel.new(@product).show_sell_range?)

        pricing_one.prices = [{ regular: 3 }]
        pricing_two.prices = [{ regular: 3 }]
        refute(ProductViewModel.new(@product).show_sell_range?)

        pricing_one.prices = [{ regular: 3 }]
        pricing_two.prices = [{ regular: 5 }]
        assert(ProductViewModel.new(@product).show_sell_range?)
      end

      def test_show_original_range
        @product.variants = [{ sku: 'SKU1' }, { sku: 'SKU2' }]
        pricing_one = create_pricing_sku(id: 'SKU1')
        pricing_two = create_pricing_sku(id: 'SKU2')

        pricing_one.set(prices: [])
        pricing_two.set(prices: [])
        refute(ProductViewModel.new(@product).show_original_range?)

        pricing_one.prices = [{ regular: 3 }]
        pricing_two.prices = [{ regular: 3 }]
        refute(ProductViewModel.new(@product).show_original_range?)

        pricing_one.prices = [{ regular: 3 }]
        pricing_two.prices = [{ regular: 5 }]
        assert(ProductViewModel.new(@product).show_original_range?)
      end

      def test_original_min_price
        @product.variants = [{ sku: 'SKU1' }, { sku: 'SKU2' }]
        pricing_one = create_pricing_sku(id: 'SKU1')
        pricing_two = create_pricing_sku(id: 'SKU2')

        pricing_one.update_attributes!(msrp: 5)
        pricing_two.update_attributes!(msrp: 6)
        pricing_one.prices = [{ regular: 3 }]
        pricing_two.prices = [{ regular: 5 }]
        assert_equal(5.to_m, ProductViewModel.new(@product).original_min_price)

        pricing_one.update_attributes!(msrp: nil)
        pricing_two.update_attributes!(msrp: nil)
        assert_equal(3.to_m, ProductViewModel.new(@product).original_min_price)

        pricing_one.update_attributes!(on_sale: true, msrp: 1)
        pricing_two.update_attributes!(msrp: 6)
        pricing_one.prices = [{ regular: 3, sale: 2 }]
        pricing_two.prices = [{ regular: 5 }]
        assert_equal(3.to_m, ProductViewModel.new(@product).original_min_price)
      end

      def test_original_max_price
        @product.variants = [{ sku: 'SKU1' }, { sku: 'SKU2' }]
        pricing_one = create_pricing_sku(id: 'SKU1')
        pricing_two = create_pricing_sku(id: 'SKU2')

        pricing_one.update_attributes!(msrp: 2)
        pricing_two.update_attributes!(msrp: 1)
        pricing_one.prices = [{ regular: 1 }]
        pricing_two.prices = [{ regular: 1 }]
        assert_equal(2.to_m, ProductViewModel.new(@product).original_max_price)

        pricing_one.update_attributes!(msrp: nil)
        pricing_two.update_attributes!(msrp: nil)
        assert_equal(1.to_m, ProductViewModel.new(@product).original_max_price)

        pricing_one.update_attributes!(on_sale: true, msrp: 1)
        pricing_two.update_attributes!(msrp: nil)
        pricing_one.prices = [{ regular: 2, sale: 2 }]
        pricing_two.prices = [{ regular: 3 }]
        assert_equal(3.to_m, ProductViewModel.new(@product).original_max_price)
      end

      def test_purchasable
        assert(ProductViewModel.new(@product).purchasable?)
        refute(ProductViewModel.new(Catalog::Product.new).purchasable?)
      end

      def test_pricing_only_has_pricing_for_the_selected_sku_if_present
        @product.variants = [{ sku: 'SKU1' }, { sku: 'SKU2' }]
        view_model = ProductViewModel.new(@product, sku: 'SKU1')
        assert_equal(['SKU1'], view_model.pricing.skus)
      end

      def test_browser_title
        assert_equal('test', ProductViewModel.new(@product).browser_title)
      end

      def test_meta_description
        @product.description = 'foo bar'
        assert_equal('foo bar', ProductViewModel.new(@product).meta_description)
      end

      def test_inventory_purchasable
        product = create_product(variants: [{ sku: '1' }, { sku: '2' }])
        create_inventory(id: '1', policy: 'standard', available: 5)
        create_inventory(id: '2', policy: 'standard', available: 0)

        view_model = ProductViewModel.wrap(product)
        assert(view_model.inventory_purchasable?)
        assert(view_model.purchasable?)

        view_model = ProductViewModel.wrap(product, sku: '1')
        assert(view_model.inventory_purchasable?)
        assert(view_model.purchasable?)

        view_model = ProductViewModel.wrap(product, sku: '2')
        refute(view_model.inventory_purchasable?)
        refute(view_model.purchasable?)
      end

      def test_requires_shipping?
        product = create_product(variants: [{ sku: 'SKU1' }, { sku: 'SKU2' }])
        sku_1 = create_fulfillment_sku(id: 'SKU1', policy: 'download', file: product_image_file_path)
        sku_2 = create_fulfillment_sku(id: 'SKU2', policy: 'shipping')

        view_model = ProductViewModel.wrap(product)
        assert(view_model.requires_shipping?)

        view_model = ProductViewModel.wrap(product, sku: 'SKU1')
        refute(view_model.requires_shipping?)

        view_model = ProductViewModel.wrap(product, sku: 'SKU2')
        assert(view_model.requires_shipping?)
      end
    end
  end
end
