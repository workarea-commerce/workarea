require 'test_helper'

module Workarea
  module Admin
    class CategoriesSystemTest < SystemTest
      include Admin::IntegrationTest
      include Storefront::SystemTest

      def test_managing_categories
        visit admin.catalog_categories_path

        click_link 'Add New Category'
        fill_in 'category[name]', with: 'Test Category'
        click_button 'save_setup'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Products'))

        click_link t('workarea.admin.create_catalog_categories.products.create_rules')

        select t('workarea.admin.fields.search').downcase, from: 'product_rule[name]'
        click_button t('workarea.admin.product_rules.index.add_rule')
        fill_in 'product_rule[value]', with: 'foo'
        click_button t('workarea.admin.actions.save')
        assert(page.has_content?('Success'))
        click_link t('workarea.admin.create_catalog_categories.rules.continue_to_content')

        assert(page.has_content?('Content'))
        click_link 'Continue to Taxonomy'

        assert(page.has_content?('Taxonomy'))
        click_button 'save_taxonomy'

        assert(page.has_content?('Success'))
        assert(page.has_content?('navigation'))
        click_button 'save_navigation'
        assert(page.has_content?('Success'))

        click_button 'publish'
        assert(page.has_content?('Success'))
        assert(page.has_content?('Test Category'))

        click_link 'Attributes'
        fill_in 'category[name]', with: 'Edited Category'
        click_button 'save_category'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Edited Category'))
        click_link 'Delete'

        assert_equal(admin.catalog_categories_path, current_path)
        assert(page.has_no_content?('Edited Category'))
      end

      def test_rules_in_creation
        create_product(name: 'Foo One')
        create_product(name: 'Foo Two')
        create_category(
          name: 'Other',
          product_ids: [create_product(name: 'Bar').id]
        )

        visit admin.catalog_categories_path

        click_link 'Add New Category'
        fill_in 'category[name]', with: 'Test Category'
        click_button 'save_setup'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Products'))

        click_link t('workarea.admin.create_catalog_categories.products.create_rules')

        select t('workarea.admin.fields.search').downcase, from: 'product_rule[name]'
        click_button t('workarea.admin.product_rules.index.add_rule')

        fill_in 'product_rule[value]', with: 'baz'
        assert(page.has_no_content?('Foo One'))
        assert(page.has_no_content?('Foo Two'))
        assert(page.has_no_content?('Bar'))

        fill_in 'product_rule[value]', with: 'foo'
        assert(page.has_content?('Foo One'))
        assert(page.has_content?('Foo Two'))
        assert(page.has_no_content?('Bar'))

        click_button t('workarea.admin.actions.save')

        assert(page.has_content?('Success'))
        assert(page.has_content?('Foo One'))
        assert(page.has_content?('Foo Two'))
        assert(page.has_no_content?('Bar'))

        click_link t('workarea.admin.actions.edit')
        fill_in 'product_rule[value]', with: 'one'
        click_button t('workarea.admin.actions.save')

        assert(page.has_content?('Success'))
        assert(page.has_content?('Foo One'))
        assert(page.has_no_content?('Foo Two'))
        assert(page.has_no_content?('Bar'))

        click_link t('workarea.admin.actions.remove')
        assert(page.has_content?('Success'))
        assert(page.has_no_content?('Foo One'))
        assert(page.has_no_content?('Foo Two'))
        assert(page.has_no_content?('Bar'))

        select t('workarea.admin.fields.category').downcase, from: 'product_rule[name]'
        click_button t('workarea.admin.product_rules.index.add_rule')

        find('.select2-selection--multiple').click
        find('.select2-results__option', text: 'Other').click
        assert(page.has_no_content?('Foo One'))
        assert(page.has_no_content?('Foo Two'))
        assert(page.has_content?('Bar'))
        click_button t('workarea.admin.actions.save')

        assert(page.has_content?('Success'))
        assert(page.has_content?('Other'))
        assert(page.has_no_content?('Foo One'))
        assert(page.has_no_content?('Foo Two'))
        assert(page.has_content?('Bar'))
      end

      def test_manually_merchandising_in_creation
        (1..3).each do |i|
          create_product(
            name: "Test Product #{i}",
            variants: [{ sku: "SKU1#{i}", regular: 25.00 * i }]
          )
        end

        # previewing in new form

        visit admin.create_catalog_categories_path
        fill_in 'category[name]', with: 'Test Category'
        click_button 'save_setup'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Products'))

        click_link t('workarea.admin.create_catalog_categories.products.pick_products')

        select 'Name', from: 'sort'

        assert(page.has_ordered_text?('Test Product 1', 'Test Product 2', 'Test Product 3'))

        click_link 'Test Product 1'

        within '#product_search_form' do
          fill_in 'q', with: 'Shoes'
          click_button 'search_products'
        end

        click_link 'Start over'

        assert(page.has_content?('Test Product 2'))
        assert(page.has_content?('Test Product 3'))
      end

      def test_insights
        category = create_category

        Metrics::CategoryByDay.inc(
          key: { category_id: category.id },
          at: Time.zone.local(2018, 10, 27),
          views: 333,
          orders: 444,
          units_sold: 555,
          revenue: 666.to_m
        )

        travel_to Time.zone.local(2018, 10, 30)

        visit admin.catalog_category_path(category)
        assert(page.has_content?('333'))
        assert(page.has_content?('444'))
        assert(page.has_content?('555'))

        click_link t('workarea.admin.catalog_categories.cards.insights.title')
        assert(page.has_content?('333'))
        assert(page.has_content?('444'))
        assert(page.has_content?('555'))
      end
    end
  end
end
