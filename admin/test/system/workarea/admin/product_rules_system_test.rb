require 'test_helper'

module Workarea
  module Admin
    class ProductRulesSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_managing_rules
        # To avoid intermittent test failures that may occur between when a
        # product is created before midnight on the last day of the month and
        # the datepicker assertions, below, occurring after midnight on the
        # first day of a new month, we create the products one day in the
        # future. This is because `travel_to` works on the server, but the
        # client time remains unaffected, thus the datepicker will always be
        # initialized to use the current time that the test is run.
        travel_to 1.day.from_now

        create_product(name: 'Foo One')
        create_product(name: 'Foo Two')
        other_category = create_category(
          name: 'Other',
          product_ids: [create_product(name: 'Bar').id]
        )
        category = create_category(product_rules: [])

        visit admin.catalog_category_path(category)
        assert(page.has_content?(t('workarea.admin.product_rules.card.description')))
        click_link t('workarea.admin.product_rules.card.header')

        assert(page.has_content?(t('workarea.admin.product_rules.index.no_rules')))

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
        assert(page.has_content?('Foo One'))
        assert(page.has_no_content?('Foo Two'))
        assert(page.has_no_content?('Bar'))

        click_button t('workarea.admin.actions.save')

        assert(page.has_content?('Success'))
        assert(page.has_content?('Foo One'))
        assert(page.has_no_content?('Foo Two'))
        assert(page.has_no_content?('Bar'))

        click_link t('workarea.admin.actions.remove')
        assert(page.has_content?('Success'))

        select t('workarea.admin.fields.created_at').downcase, from: 'product_rule[name]'
        click_button t('workarea.admin.product_rules.index.add_rule')

        find('#product_rule_value').click
        within '.ui-datepicker-calendar' do
          find('.ui-datepicker-today a').click
        end
        click_button t('workarea.admin.actions.save')

        assert(page.has_content?('Foo One'))
        assert(page.has_content?('Foo Two'))
        assert(page.has_content?('Bar'))

        click_link t('workarea.admin.actions.remove')
        assert(page.has_content?('Success'))
        assert(page.has_content?(t('workarea.admin.product_rules.index.no_rules')))
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

        click_on 'Timeline'

        assert_text(
          t(
            'workarea.admin.activities.catalog_category_product_rule_create',
            category: 'Test Category',
            name: 'category',
            operator: 'equal',
            value: other_category.name
          )
        )
      end

      def test_showing_undisplayable_products
        create_product(name: 'Bar Baz')
        create_product(name: 'Foo One')
        create_product(name: 'Foo Two')
        create_product(name: 'Foo Three', active: false)
        create_product(name: 'Foo Four', variants: [])

        category = create_category(product_rules: [])

        visit admin.catalog_category_path(category)
        click_link t('workarea.admin.product_rules.card.header')

        select t('workarea.admin.fields.search').downcase, from: 'product_rule[name]'
        click_button t('workarea.admin.product_rules.index.add_rule')

        fill_in 'product_rule[value]', with: 'foo'
        assert(page.has_content?('Foo One'))
        assert(page.has_content?('Foo Two'))
        assert(page.has_no_content?('Foo Three'))
        assert(page.has_no_content?('Foo Four'))
        assert(page.has_no_content?('Bar Baz'))

        click_link t('workarea.admin.product_rules.preview.show_undisplayable')

        assert(page.has_content?('Foo One'))
        assert(page.has_content?('Foo Two'))
        assert(page.has_content?('Foo Three'))
        assert(page.has_content?('Foo Four'))
        assert(page.has_no_content?('Bar Baz'))

        click_button t('workarea.admin.actions.save')
        assert(page.has_content?('Success'))
        assert(page.has_content?('Foo One'))
        assert(page.has_content?('Foo Two'))
        assert(page.has_no_content?('Foo Three'))
        assert(page.has_no_content?('Foo Four'))
        assert(page.has_no_content?('Bar Baz'))
      end
    end
  end
end
