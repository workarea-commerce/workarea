require 'test_helper'

module Workarea
  module Storefront
    class CategoriesSystemTest < Workarea::SystemTest
      include Storefront::SystemTest
      include BreakpointHelpers
      setup :set_products
      setup :set_search_settings

      def set_products
        @products =
          [
            create_product(id:          'PROD1',
                           name:        'Integration Product 1',
                           filters:     { 'Size' => 'Medium', 'Color' => ['Green', 'Red'] },
                           created_at:  Time.current - 1.hour,
                           variants:    [{ sku: 'SKU1', regular: 10.to_m }]),
            create_product(id:          'PROD2',
                           name:        'Integration Product 2',
                           filters:     { 'Size' => ['Medium', 'Small'], 'Color' => 'Red' },
                           created_at:  Time.current - 2.hour,
                           variants:    [{ sku: 'SKU2', regular: 5.to_m, details: { 'Size' => 'Medium' } },
                                         { sku: 'SKU4', regular: 5.to_m, details: { 'Size' => 'Large' } }]),
            create_product(id:       'PROD3',
                           name:     'Integration Product 3',
                           filters:  { 'Size' => ['Medium', 'Small'], 'Color' => 'Blue' },
                           created_at: Time.current - 3.hour,
                           variants: [{ sku: 'SKU3', regular: 2.to_m }]),
             create_product(id:       'PROD5',
                           name:     'Integration Product 5',
                           filters:  { 'Size' => ['Medium', 'Small'], 'Color' => 'Blue' },
                           created_at: Time.current - 3.hour,
                           variants: [{ sku: 'SKU5', regular: 2.to_m }]),
             create_product(id:       'PROD6',
                           name:     'Integration Product 6',
                           filters:  { 'Size' => ['Medium', 'Small'], 'Color' => 'Blue' },
                           created_at: Time.current - 3.hour,
                           variants: [{ sku: 'SKU6', regular: 2.to_m }]),
             create_product(id:       'PROD7',
                           name:     'Integration Product 7',
                           filters:  { 'Size' => ['Medium', 'Small'], 'Color' => 'Blue' },
                           created_at: Time.current - 3.hour,
                           variants: [{ sku: 'SKU7', regular: 2.to_m }])
          ]
      end

      def set_search_settings
        update_search_settings
      end

      def categorize_products(category)
        category.update_attributes!(
          product_ids: [@products.second.id, @products.first.id, @products.fourth.id]
        )
      end

      def test_basic_category_setup
        category = create_category
        categorize_products(category)

        visit storefront.category_path(category)

        assert(page.has_content?('Integration Product 1'))
        assert(page.has_content?('Integration Product 2'))
        assert(page.has_content?('10.00'))
        assert(page.has_content?('5.00'))
        assert(page.has_content?('Medium (3)'))
        assert(page.has_content?('Small (2)'))
      end

      def test_sorting_products
        category = create_category
        categorize_products(category)

        visit storefront.category_path(category)

        select(t('workarea.sorts.price_asc'), from: 'sort_top')
        assert(page.has_ordered_text?(
          'Integration Product 2',
          'Integration Product 1'
        ))

        visit storefront.category_path(category)
        select(t('workarea.sorts.price_desc'), from: 'sort_top')
        assert(page.has_ordered_text?(
          'Integration Product 1',
          'Integration Product 2'
        ))

        visit storefront.category_path(category)
        select(t('workarea.sorts.newest'), from: 'sort_top')
        assert(page.has_ordered_text?(
          'Integration Product 1',
          'Integration Product 2'
        ))

        create_product_by_week(product_id: 'PROD2', orders: 3)
        create_product_by_week(product_id: 'PROD1', orders: 2)
        create_product_by_week(product_id: 'PROD3', orders: 1)
        @products.each { |p| IndexProduct.perform(p) }

        visit storefront.category_path(category)
        select(t('workarea.sorts.top_sellers'), from: 'sort_top')
        assert(page.has_ordered_text?(
          'Integration Product 2',
          'Integration Product 1'
        ))
      end

      def test_products_out_of_stock
        category = create_category
        categorize_products(category)

        create_inventory(id: 'SKU1', policy: 'standard', available: 0)

        visit storefront.category_path(category)
        assert(page.has_no_content?('Integration Product 1'))
      end

      def test_filtering_products
        category = create_category
        categorize_products(category)

        visit storefront.category_path(category)

        Capybara.match = :first
        price_range = "#{currency}10.00 - #{currency}19.99"
        click_link "#{price_range} (1)"

        assert(page.has_content?('Integration Product 1'))
        assert(page.has_no_content?('Integration Product 2'))

        click_link "#{price_range} #{t('workarea.storefront.products.remove_filter')}"

        assert(page.has_content?('Integration Product 1'))
        assert(page.has_content?('Integration Product 2'))

        click_link 'Green (1)'

        assert(page.has_content?('Integration Product 1'))
        assert(page.has_no_content?('Integration Product 2'))

        click_link "Green #{t('workarea.storefront.products.remove_filter')}"

        assert(page.has_content?('Integration Product 1'))
        assert(page.has_content?('Integration Product 2'))

        # Mobile Filters Nav
        resize_window_to('small')
        visit storefront.category_path(category)

        find('[data-mobile-filter-button]').click
        assert(page.has_selector?('.mobile-filters-nav', visible: true))

        within '.mobile-filters-nav' do
          assert(page.has_content?("#{price_range} (1)"))
        end

        page.execute_script("$('body').trigger('click');")
        assert(page.has_selector?('.mobile-filters-nav', visible: false))

        find('[data-mobile-filter-button]').click
        assert(page.has_selector?('.mobile-filters-nav', visible: true))

        within '.mobile-filters-nav' do
          click_button t('workarea.storefront.products.filter_nav_close_button')
        end

        assert(page.has_selector?('.mobile-filters-nav', visible: false))
      end

      def test_filtering_products_and_sorting
        category = create_category
        categorize_products(category)

        visit storefront.category_path(category)

        Capybara.match = :first
        price_range = "#{currency}10.00 - #{currency}19.99"
        click_link "#{price_range} (1)"

        assert(page.has_content?('Integration Product 1'))
        assert(page.has_no_content?('Integration Product 2'))

        select(t('workarea.sorts.price_asc'), from: 'sort_top')

        assert(page.has_content?('Integration Product 1'))
        assert(page.has_no_content?('Integration Product 2'))
      end

      def test_category_rules
        category = create_category(
          name: 'Integration Category',
          product_rules: [
            { name: 'color', operator: 'equals', value: 'Green' }
          ]
        )

        visit storefront.category_path(category)

        assert(page.has_content?('Integration Product 1'))
        assert(page.has_no_content?('Integration Product 2'))

        category = create_category(name: 'Integration Category')
        category.product_rules.create!(
          name: 'on_sale',
          operator: 'equals',
          value: 'true'
        )

        sku = Pricing::Sku.find_or_create_by(id: @products.first.skus.first)
        sku.update_attributes(on_sale: true)

        visit storefront.category_path(category)

        assert(page.has_content?('Integration Product 1'))
        assert(page.has_no_content?('Integration Product 2'))

        category = create_category(name: 'Integration Category 1')
        category.product_rules.create!(
          name: 'price',
          operator: 'less_than',
          value: '8'
        )

        visit storefront.category_path(category)

        assert(page.has_content?('Integration Product 2'))
        assert(page.has_no_content?('Integration Product 1'))
      end

      def test_custom_filters
        category = create_category
        categorize_products(category)

        visit storefront.category_path(category)

        assert(page.has_content?('Size'))
        assert(page.has_content?('Medium (3)'))

        assert_text("#{currency}10.00 - #{currency}19.99 (1)")

        category.terms_facets = ['Color']
        category.range_facets = { 'price' => [{ 'to' => 10 }, { 'from' => 10 }] }
        category.save!

        visit storefront.category_path(category)

        assert(page.has_no_content?('Size'))
        assert(page.has_no_content?('Medium (3)'))

        under = t('workarea.facets.price_range.under', price: "#{currency}10.00")
        over = t('workarea.facets.price_range.over', price: "#{currency}10.00")

        assert(page.has_content?("#{under} (2)"))
        assert(page.has_content?("#{over} (1)"))
      end
    end
  end
end
