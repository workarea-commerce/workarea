require 'test_helper'

module Workarea
  module Admin
    class FeaturedProductsSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_managing_featured_products
        create_product(name: 'Foo')
        create_product(name: 'Bar')
        create_product(name: 'Baz', active: false)
        category = create_category
        visit admin.catalog_category_path(category)

        click_link t('workarea.admin.catalog_categories.cards.featured_products.title')
        assert(page.has_content?('Foo'))
        assert(page.has_content?('Bar'))
        assert(page.has_content?('Baz'))
        assert(page.has_content?(t('workarea.admin.featured_products.statuses.inactive')))

        click_link 'Foo'
        assert(page.has_content?('Success'))
        assert(page.has_selector?('.product-summary__remove'))
        click_link t('workarea.admin.featured_products.select.sort_link')

        assert(page.has_content?('Foo'))
        assert(page.has_no_content?('Bar'))
        click_link t('workarea.admin.featured_products.edit.browse_link')

        assert(page.has_selector?('.product-summary__remove'))
        click_link 'Foo'
        assert(page.has_content?('Success'))
        assert(page.has_no_selector?('.product-summary__remove'))
        click_link t('workarea.admin.featured_products.select.sort_link')

        assert(page.has_no_content?('Foo'))
        assert(page.has_no_content?('Bar'))
        assert(page.has_no_selector?('#product_ids_'))
      end
    end
  end
end
