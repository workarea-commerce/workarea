require 'test_helper'

module Workarea
  module Storefront
    class ProductsSystemTest < Workarea::SystemTest
      setup :set_product

      def set_product
        @product = create_product(
            name: 'Integration Product',
            variants: [
              { sku: 'SKU1', regular: 10.to_m },
              { sku: 'SKU2', regular: 15.to_m },
              { sku: 'SKU3', regular: 15.to_m }
            ]
          )
      end

      def test_showing_a_product
        visit storefront.product_path(@product)
        assert(page.has_content?('Integration Product'))
        assert(page.has_content?('10.00'))
        assert(page.has_content?('15.00'))
        assert(page.has_select?('sku', options: ['Select options', 'SKU1', 'SKU2', 'SKU3']))
      end

      def test_showing_a_product_with_inactive_skus
        @product.variants.first.update_attributes!(active: false)

        visit storefront.product_path(@product)
        assert(page.has_content?('Integration Product'))
        assert(page.has_no_content?('10.00'))
        assert(page.has_content?('15.00'))
        assert(page.has_select?('sku', options: ['Select options', 'SKU2', 'SKU3']))
      end

      def test_showing_custom_detail_page_templates
        visit storefront.product_path(create_product(template: 'test'))
        assert(page.has_content?('This is for testing custom template rendering'))
      end

      def test_showing_a_specific_variant_by_sku
        visit storefront.product_path(@product, sku: 'SKU1')

        within '.product-details' do
          assert(has_content?('Integration Product'))
          assert(has_content?('10.00'))
          assert(has_no_content?('15.00'))
        end

        visit storefront.product_path(@product, sku: 'SKU2')

        within '.product-details' do
          assert(has_content?('15.00'))
        end
      end

      def test_showing_a_product_with_no_prices
        Pricing::Sku.find('SKU1').update!(prices: [])

        visit storefront.product_path(@product, sku: 'SKU1')

        assert(page.has_no_content?('10.00'))
        assert(page.has_content?(t('workarea.storefront.products.unavailable')))
      end

      def test_changing_generic_skus_multiple_times
        visit storefront.product_path(@product)

        select("SKU1", from: "sku")
        assert(page.has_content?('10.00'))

        select("SKU2", from: "sku")
        assert(page.has_content?('15.00'))
      end

      def test_option_selects_template
        product = create_product(
          name: 'Option Selects Product',
          template: 'option_selects',
          variants: [
            {
               sku: 'SKU1',
               regular: 10.to_m,
               details: { color: 'Red', size: 'Large', material: 'Cotton' }
            },
            {
               sku: 'SKU2',
               regular: 15.to_m,
               details: { color: 'Red', size: 'Small', material: 'Cotton' }
            },
            {
               sku: 'SKU3',
               regular: 15.to_m,
               details: { color: 'Blue', size: 'Small', material: 'Suede' }
            }
          ]
        )

        visit storefront.product_path(product)
        select_color = t('workarea.storefront.products.select_option', name: 'Color')
        select_size = t('workarea.storefront.products.select_option', name: 'Size')
        select_material = t('workarea.storefront.products.select_option', name: 'Material')

        assert(page.has_select?('color', options: [select_color, 'Red', 'Blue']))
        assert(page.has_select?('size', options: [select_size, 'Large', 'Small']))
        assert(page.has_select?('material', options: [select_material, 'Cotton', 'Suede']))

        select 'Red', from: 'color'
        assert(page.has_select?('color', options: [select_color, 'Red', 'Blue']))
        assert(page.has_select?('size', options: [select_size, 'Large', 'Small']))
        assert(page.has_select?('material', options: [select_material, 'Cotton']))

        select 'Small', from: 'size'
        assert(page.has_select?('color', options: [select_color, 'Red', 'Blue']))
        assert(page.has_select?('size', options: [select_size, 'Large', 'Small']))
        assert(page.has_select?('material', options: [select_material, 'Cotton']))

        select 'Blue', from: 'color'
        assert(page.has_select?('color', options: [select_color, 'Red', 'Blue']))
        assert(page.has_select?('size', options: [select_size, 'Small']))
        assert(page.has_select?('material', options: [select_material, 'Suede']))

        select select_color, from: 'color'
        assert(page.has_select?('color', options: [select_color, 'Red', 'Blue']))
        assert(page.has_select?('size', options: [select_size, 'Large', 'Small']))
        assert(page.has_select?('material', options: [select_material, 'Cotton', 'Suede']))

        select 'Blue', from: 'color'
        click_link t('workarea.storefront.products.clear_selections')
        assert(page.has_select?('color', options: [select_color, 'Red', 'Blue']))
        assert(page.has_select?('size', options: [select_size, 'Large', 'Small']))
        assert(page.has_select?('material', options: [select_material, 'Cotton', 'Suede']))

        visit storefront.product_path(product, sku: 'SKU1')
        assert(page.has_select?('color', options: [select_color, 'Red'], selected: 'Red'))
        assert(page.has_select?('size', options: [select_size, 'Large', 'Small'], selected: 'Large'))
        assert(page.has_select?('material', options: [select_material, 'Cotton'], selected: 'Cotton'))
      end

      def test_option_thumbnails_template
        product = create_product(
          template: 'option_thumbnails',
          variants: [
            {
               sku: 'SKU1',
               regular: 10.to_m,
               details: { color: 'Red', size: 'Large', material: 'Cotton' }
            },
            {
               sku: 'SKU2',
               regular: 15.to_m,
               details: { color: 'Red', size: 'Small', material: 'Cotton' }
            },
            {
               sku: 'SKU3',
               regular: 15.to_m,
               details: { color: 'Blue', size: 'Small', material: 'Suede' }
            }
          ]
        )

        visit storefront.product_path(product)

        within '.product-details' do
          assert(page.has_content?('Red'))
          assert(page.has_content?('Blue'))
          assert(page.has_content?('Large'))
          assert(page.has_content?('Small'))
          assert(page.has_content?('Cotton'))
          assert(page.has_content?('Suede'))

          click_link 'Red'
          assert(page.has_content?('Red'))
          assert(page.has_content?('Blue'))
          assert(page.has_content?('Large'))
          assert(page.has_content?('Small'))
          assert(page.has_content?('Cotton'))
          assert(page.has_no_content?('Suede'))

          click_link 'Small'
          assert(page.has_content?('Red'))
          assert(page.has_content?('Blue'))
          assert(page.has_content?('Large'))
          assert(page.has_content?('Small'))
          assert(page.has_content?('Cotton'))
          assert(page.has_no_content?('Suede'))

          click_link 'Blue'
          assert(page.has_content?('Red'))
          assert(page.has_content?('Blue'))
          assert(page.has_no_content?('Large'))
          assert(page.has_content?('Small'))
          assert(page.has_no_content?('Cotton'))
          assert(page.has_content?('Suede'))

          click_link 'Blue' # to unselect
          assert(page.has_content?('Red'))
          assert(page.has_content?('Blue'))
          assert(page.has_content?('Large'))
          assert(page.has_content?('Small'))
          assert(page.has_content?('Cotton'))
          assert(page.has_content?('Suede'))

          click_link 'Blue'
          click_link t('workarea.storefront.products.clear_selections')
          assert(page.has_content?('Red'))
          assert(page.has_content?('Blue'))
          assert(page.has_content?('Large'))
          assert(page.has_content?('Small'))
          assert(page.has_content?('Cotton'))
          assert(page.has_content?('Suede'))
        end

        visit storefront.product_path(product, sku: 'SKU1')
        within '.product-details' do
          assert(page.has_content?('Red'))
          assert(page.has_no_content?('Blue'))
          assert(page.has_content?('Large'))
          assert(page.has_content?('Small'))
          assert(page.has_content?('Cotton'))
          assert(page.has_no_content?('Suede'))
          assert(page.has_selector?('.option-button--red.option-button--active'))
          assert(page.has_selector?('.option-button--large.option-button--active'))
          assert(page.has_selector?('.option-button--cotton.option-button--active'))
        end

        visit storefront.product_path(product)
        #
        # No SKU selected - caught by client side validation
        #
        click_button t('workarea.storefront.products.add_to_cart')
        assert(page.has_content?(t('validate.required')))

        #
        # SKU selected - able to add to cart
        #
        click_link 'Red'
        click_link 'Cotton'
        click_link 'Small'
        assert(page.has_no_content?(t('validate.required')))
        click_button t('workarea.storefront.products.add_to_cart')
        assert(page.has_content?('Success'))
      end
    end
  end
end
