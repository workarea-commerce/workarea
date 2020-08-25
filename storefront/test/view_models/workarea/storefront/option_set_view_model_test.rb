require 'test_helper'

module Workarea
  module Storefront
    class OptionSetViewModelTest < Workarea::TestCase
      class TestViewModel < ProductViewModel
        include OptionSetViewModel
      end

      def test_pricing_uses_sku_from_params
        product = create_product(
          variants: [
            { sku: 'SKU1', regular: 5.to_m },
            { sku: 'SKU2', regular: 6.to_m }
          ]
       )

       view_model = TestViewModel.wrap(product, sku: 'SKU1')
       assert_equal(5.to_m, view_model.sell_min_price)

       view_model = TestViewModel.wrap(product, sku: 'SKU2')
       assert_equal(6.to_m, view_model.sell_min_price)
      end

      def test_pricing_uses_sku_derived_from_options
        product = create_product(
          variants: [
            {
              sku: 'SKU1',
              regular: 5.to_m,
              details: { 'Size' => 'Medium', 'Color' => 'Red' }
            },
            {
              sku: 'SKU2',
              regular: 6.to_m,
              details: { 'Size' => 'Large', 'Color' => 'Red' }
            }
          ]
       )

       view_model = TestViewModel.wrap(product, color: 'Red')
       assert_equal(5.to_m, view_model.sell_min_price)

       view_model = TestViewModel.wrap(product, color: 'Red', size: 'Large')
       assert_equal(6.to_m, view_model.sell_min_price)
      end

      def test_only_including_images_that_match_selected_options
        product = create_product(
          variants: [
            { sku: 'SKU1', details: { 'Color' => 'Red' } },
            { sku: 'SKU2', details: { 'Color' => 'Blue' } }
          ],
          images: [
            { image: product_image_file_path, option: 'blue' },
            { image: product_image_file_path, option: 'red' }
          ]
       )

       view_model = TestViewModel.wrap(product, color: 'Red')
       assert_equal(1, view_model.images.size)
       assert_equal('red', view_model.images.first.option)

       view_model = TestViewModel.wrap(product, color: 'Blue')
       assert_equal(1, view_model.images.size)
       assert_equal('blue', view_model.images.first.option)

       view_model = TestViewModel.wrap(product, color: %w(Blue Green))
       assert_equal(1, view_model.images.size)
       assert_equal('blue', view_model.images.first.option)
      end

      def test_images_with_nil_option
        product = create_product(
          images: [{ option: nil }],
          variants: [
            { sku: 'SKU1', regular: 5.to_m },
            { sku: 'SKU2', regular: 6.to_m }
          ]
       )

       view_model = TestViewModel.wrap(product, sku: 'SKU1')
       assert_equal(1, view_model.images.size)
      end

      def test_images_match_primary_when_no_matching_options_selected
        product = create_product(
          variants: [
            { sku: 'SKU1', details: { 'Color' => 'Red' } },
            { sku: 'SKU2', details: { 'Color' => 'Blue' } }
          ],
          images: [
            { image: product_image_file_path, option: 'blue' },
            { image: product_image_file_path, option: 'red' }
          ]
       )

       view_model = TestViewModel.wrap(product)
       assert_equal(1, view_model.images.size)
       assert_equal('blue', view_model.images.first.option)

       product.images.find_by(option: 'blue').update_attributes!(position: 999)
       product.images.find_by(option: 'red').update_attributes!(position: 0)
       product.reload

       view_model = TestViewModel.wrap(product)
       assert_equal(1, view_model.images.size)
       assert_equal('red', view_model.images.first.option)
      end

      def test_images_sorted_by_position
        product = create_product(
          variants: [
            { sku: 'SKU1', details: { 'Color' => 'Red' } },
            { sku: 'SKU2', details: { 'Color' => 'Blue' } }
          ],
          images: [
            { image: product_image_file_path, option: 'red', position: 0 },
            { image: product_image_file_path, option: 'red', position: 9 },
            { image: product_image_file_path, option: 'red', position: 5 },
            { image: product_image_file_path, option: 'blue', position: 3 },
            { image: product_image_file_path, option: 'blue', position: 2 },
            { image: product_image_file_path, option: 'blue', position: 1 }
          ]
        )
        product.reload
        primary_view_model = TestViewModel.wrap(product)
        option_view_model = TestViewModel.wrap(product, color: 'Blue')

        assert_equal([0, 5, 9], primary_view_model.images.map(&:position))
        assert_equal([1, 2, 3], option_view_model.images.map(&:position))
      end

      def test_has_option_derived_sku_in_cache_key
        product = create_product(
          variants: [
            {
              sku: 'SKU1',
              regular: 5.to_m,
              details: { 'Size' => 'Medium', 'Color' => 'Red' }
            },
            {
              sku: 'SKU2',
              regular: 6.to_m,
              details: { 'Size' => 'Large', 'Color' => 'Red' }
            }
          ]
       )

       view_model = TestViewModel.wrap(product, color: 'Red', size: 'Medium')
       assert_includes(view_model.cache_key, 'SKU1')

       view_model = TestViewModel.wrap(product, color: 'Red', size: 'Large')
       assert_includes(view_model.cache_key, 'SKU2')
      end
    end
  end
end
