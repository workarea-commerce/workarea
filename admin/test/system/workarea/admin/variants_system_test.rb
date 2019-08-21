require 'test_helper'

module Workarea
  module Admin
    class VariantsSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_managing_variants
        product = create_product(variants: [])
        visit admin.catalog_product_path(product)
        click_link 'Variants'
        click_link 'Add New'
        assert_current_path(admin.new_catalog_product_variant_path(product))

        fill_in 'variant[name]', with: 'Test'
        fill_in 'variant[sku]', with: 'SKU1234'
        click_button 'Create Variant'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Test'))

        click_link 'SKU1234'
        fill_in 'variant[name]', with: 'Foo'
        find('.toggle-button__label--positive').click

        click_button 'Save Changes'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Foo'))

        click_button 'Delete'
        assert(page.has_content?('Success'))
        assert(page.has_no_content?('Foo'))
        assert(page.has_no_selector?('#details_'))
      end

      def test_sorting_variants
        product = create_product(variants: [])
        product.variants.create!(sku: 'Foo')
        product.variants.create!(sku: 'Bar')
        product.variants.create!(sku: 'Baz')

        visit admin.catalog_product_path(product)
        click_link t('workarea.admin.catalog_products.cards.variants.title')
        assert(page.has_ordered_text?('Foo', 'Bar', 'Baz'))

        assert(page.has_selector?('.ui-sortable'))
      end
    end
  end
end
