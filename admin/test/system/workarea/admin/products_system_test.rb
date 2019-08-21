require 'test_helper'

module Workarea
  module Admin
    class ProductsSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_searching
        create_product(
          name: 'Test Product 1',
          variants: [{ sku: 'SKU1', regular: 10.to_m }]
        )

        create_product(
          name: 'Test Product 2',
          variants: [{ sku: 'SKU2', regular: 5.to_m }]
        )

        visit admin.catalog_products_path

        within '#product_search_form' do
          fill_in 'q', with: 'test'
          click_button 'search_products'
        end

        assert(page.has_content?('Test Product 1'))
        assert(page.has_content?('Test Product 2'))
      end

      def test_managing_products
        create_category(name: 'Test Category')

        visit admin.catalog_products_path
        click_link 'Add New Product'

        fill_in 'product[name]', with: 'Test Product'
        click_button 'save_setup'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Variants'))

        fill_in 'variants[][sku]', with: 'TESTSKU'
        fill_in 'variants[][price]', match: :first, with: '20'
        fill_in 'variants[][inventory]', match: :first, with: '99'
        click_button 'save_variants'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Images'))

        attach_file 'images[][image]', product_image_file_path
        click_button 'save_images'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Details'))
        assert(page.has_no_selector?('#details_'))
        click_button 'save_details'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Content'))

        page.execute_script(<<-js
          $("body", $("iframe.wysihtml-sandbox").contents())
            .text("Description")
          js
        )

        click_button 'save_content'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Categorization'))

        find('.select2-selection--multiple').click
        assert(page.has_content?('Test Category'))
        find('.select2-results__option', text: 'Test Category').click

        click_button 'add_categories'
        assert(page.has_content?('Success'))
        assert(page.has_content?('Test Category'))
        click_link 'Continue to Publish'

        assert(page.has_content?('Publish'))
        click_button 'publish'

        click_link 'Attributes'
        fill_in 'product[name]', with: 'Edited Product'
        click_button 'save_product'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Edited Product'))
        click_link 'Delete'

        assert_current_path(admin.catalog_products_path)
        assert(page.has_no_content?('Edited Category'))
      end

      def test_categorization_management
        product = create_product
        create_category(name: 'Foo')

        visit admin.catalog_product_path(product)
        click_link 'Categories'

        find('.select2-selection--multiple').click
        assert(page.has_content?('Foo'))
        find('.select2-results__option', text: 'Foo').click

        click_button 'add_categories'

        assert(page.has_content?('Success'))
        assert_current_path(admin.catalog_product_categorizations_path(product))
        assert(page.has_content?('Foo'))
      end

      def test_insights
        product = create_product(name: 'Foo 1')

        Metrics::ProductByDay.inc(
          key: { product_id: product.id },
          at: Time.zone.local(2018, 10, 27),
          views: 333,
          orders: 444,
          units_sold: 555,
          revenue: 666.to_m
        )

        travel_to Time.zone.local(2018, 10, 30)

        visit admin.catalog_product_path(product)
        assert(page.has_content?('333'))
        assert(page.has_content?('444'))
        assert(page.has_content?('555'))

        click_link t('workarea.admin.catalog_products.cards.insights.title')
        assert(page.has_content?('333'))
        assert(page.has_content?('444'))
        assert(page.has_content?('555'))
      end
    end
  end
end
