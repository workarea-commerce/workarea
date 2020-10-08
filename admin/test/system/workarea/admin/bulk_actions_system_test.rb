require 'test_helper'

module Workarea
  module Admin
    class BulkActionsSystemTest < SystemTest
      include Admin::IntegrationTest
      include ActionView::Helpers::SanitizeHelper

      setup :create_products
      setup :set_config
      teardown :reset_config
      teardown :reset_session_storage

      def set_config
        @per_page = Workarea.config.per_page
      end

      def reset_config
        Workarea.config.per_page = @per_page
      end

      def reset_session_storage
        visit admin.catalog_products_path
        page.execute_script('window.sessionStorage.removeItem("bulkActionItems")')
      end

      def create_products
        @products = (1..5).inject([]) do |memo, i|
          memo << create_product(
            name: "Test Product #{i}",
            active: true,
            tag_list: 'remove_tag_1',
            variants: [{ sku: "SKU#{i}", regular: 10.to_m }],
            filters: { remove_filter: 'val1, val2' },
            details: { remove_name: 'value' }
          )
        end
        create_tax_category(name: 'Sales Tax', code: '001')
      end

      def test_empty_selection
        visit admin.catalog_products_path

        refute_text t('workarea.admin.shared.bulk_actions.selected')

        click_button t('workarea.admin.catalog_products.index.edit')
        assert(page.has_content?('5 Products Selected'))

        visit admin.catalog_products_path

        click_button t('workarea.admin.catalog_products.index.edit_each')
        assert(page.has_content?('5 Products Selected'))
      end

      def test_session_reset
        visit admin.catalog_products_path

        check "catalog_product_#{@products.first.id}"
        assert(page.has_content?('1 selected'))

        click_link t('workarea.admin.catalog.dashboard_link')

        visit admin.catalog_products_path
        refute_text('1 selected')
      end

      def test_persistence
        Workarea.config.per_page = 2

        visit admin.catalog_products_path

        check "catalog_product_#{@products.fourth.id}"

        click_link 'Next'
        check "catalog_product_#{@products.third.id}"

        click_link 'Previous'
        check "catalog_product_#{@products.fifth.id}"

        assert(page.has_content?('3 selected'))

        visit admin.catalog_products_path

        assert(page.has_content?('3 selected'))

        click_button t('workarea.admin.catalog_products.index.edit')
        click_link t('workarea.admin.form.cancel')

        refute_text('3 selected')
      end

      def test_select_all
        visit admin.catalog_products_path

        check 'select_all'
        assert(page.has_content?("5 #{t('workarea.admin.shared.bulk_actions.selected')}"))

        uncheck 'select_all'
        refute_text(t('workarea.admin.shared.bulk_actions.selected'))

        check 'select_all'
        uncheck "catalog_product_#{@products.fifth.id}"
        uncheck "catalog_product_#{@products.fourth.id}"
        assert(page.has_content?("3 #{t('workarea.admin.shared.bulk_actions.selected')}"))

        check 'select_all'
        refute_text(t('workarea.admin.shared.bulk_actions.selected'))

        check "catalog_product_#{@products.fifth.id}"
        check "catalog_product_#{@products.fourth.id}"
        assert(page.has_content?("2 #{t('workarea.admin.shared.bulk_actions.selected')}"))

        check 'select_all'
        refute_text(t('workarea.admin.shared.bulk_actions.selected'))
      end

      def test_bulk_editing
        visit admin.catalog_products_path

        check "catalog_product_#{@products.first.id}"
        check "catalog_product_#{@products.second.id}"

        assert(page.has_content?('2 selected'))
        click_button t('workarea.admin.catalog_products.index.edit')

        assert(page.has_content?(t('workarea.admin.bulk_action_product_edits.edit.title')))
        assert(page.has_content?(t('workarea.admin.bulk_action_product_edits.worflow.selected', label: '2 Products')))

        check 'toggle_active'
        find('#bulk_action_settings_active_false_label').click

        fill_in 'bulk_action[add_tags_list]', with: 'add_tag_2, add_tag_3'
        fill_in 'bulk_action[remove_tags_list]', with: 'remove_tag_1'

        fill_in 'filter_name', with: 'add_filter_1'
        fill_in 'filter_value', with: 'add_filter_value_1, add_filter_value_2'
        fill_in 'bulk_action[remove_filters_list]', with: 'remove_filter'

        fill_in 'attribute_name', with: 'add_attribute_1'
        fill_in 'attribute_value', with: 'add_attribute_value_1, add_attribute_value_2'
        fill_in 'bulk_action[remove_details_list]', with: 'remove_name'

        check 'toggle_tax_code'
        fill_in 'bulk_action[pricing][tax_code]', with: '001'

        check 'toggle_regular_price'
        fill_in 'bulk_action[pricing][prices][regular][amount]', with: 20

        check 'toggle_inventory_policy'
        select 'Standard', from: 'bulk_action[inventory][policy]'

        check 'toggle_inventory_available'
        fill_in 'bulk_action[inventory][available]', with: 50

        click_button t('workarea.admin.bulk_action_product_edits.edit.review_changes')

        assert(page.has_content?(t('workarea.admin.bulk_action_product_edits.review.title')))
        assert(page.has_content?(t('workarea.admin.bulk_action_product_edits.worflow.selected', label: '2 Products')))

        assert(page.has_content?("#{t('workarea.admin.fields.active')} false"))
        assert(page.has_content?('add_tag_2, add_tag_3'))
        assert(page.has_content?('remove_tag_1'))
        assert(page.has_content?('add_filter_1'))
        assert(page.has_content?('add_filter_value_1, add_filter_value_2'))
        assert(page.has_content?('remove_filter'))
        assert(page.has_content?('add_attribute_1'))
        assert(page.has_content?('add_attribute_value_1, add_attribute_value_2'))
        assert(page.has_content?('remove_name'))
        assert(page.has_content?("#{t('workarea.admin.fields.tax_code')}: 001"))
        assert_text(
          strip_tags(
            t(
              'workarea.admin.bulk_action_product_edits.review.pricing.set_html',
              kind: t('workarea.admin.bulk_action_product_edits.review.pricing.regular')
            )
          )
        )
        assert(page.has_content?("#{t('workarea.admin.fields.policy')}: standard"))
        assert(page.has_content?("#{t('workarea.admin.fields.available')}: 50"))

        click_link t('workarea.admin.bulk_action_product_edits.worflow.view_products_link')
        assert(page.has_content?(t('workarea.admin.bulk_actions.selected.heading')))
        assert(page.has_content?('Test Product 1'))
        assert(page.has_content?('Test Product 2'))
        click_link t('workarea.admin.bulk_actions.selected.back_link')

        click_link t('workarea.admin.bulk_action_product_edits.worflow.edit_step')

        find('#toggle_active').click
        fill_in 'bulk_action[remove_tags_list]', with: ''
        select 'Ignore', from: 'bulk_action[inventory][policy]'

        click_button t('workarea.admin.bulk_action_product_edits.edit.review_changes')

        assert(page.has_no_content?("#{t('workarea.admin.fields.active')}: false"))
        assert(page.has_content?('add_tag_2, add_tag_3'))
        assert(page.has_no_content?('remove_tag_1'))
        assert(page.has_content?('add_filter_1'))
        assert(page.has_content?('add_filter_value_1, add_filter_value_2'))
        assert(page.has_content?('remove_filter'))
        assert(page.has_content?('add_attribute_1'))
        assert(page.has_content?('add_attribute_value_1, add_attribute_value_2'))
        assert(page.has_content?('remove_name'))
        assert(page.has_content?("#{t('workarea.admin.fields.tax_code')}: 001"))
        assert_text(
          strip_tags(
            t(
              'workarea.admin.bulk_action_product_edits.review.pricing.set_html',
              kind: t('workarea.admin.bulk_action_product_edits.review.pricing.regular')
            )
          )
        )
        assert_text("#{Money.default_currency.symbol}20.00")
        assert(page.has_content?("#{t('workarea.admin.fields.policy')}: ignore"))
        assert(page.has_content?("#{t('workarea.admin.fields.available')}: 50"))

        click_button t('workarea.admin.bulk_action_product_edits.review.save_and_finish')
        assert(page.has_content?('Your product edits are being processed'))
      end
    end
  end
end
