require 'test_helper'

module Workarea
  module Admin
    class SequentialProductEditingSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_editing_products_in_sequence
        product_one = create_product(name: 'Foo A')
        product_two = create_product(name: 'Foo B')
        product_three = create_product(name: 'Foo C')

        visit admin.catalog_products_path
        select(Sort.name_asc.name, from: 'sort')

        check "catalog_product_#{product_one.id}"
        check "catalog_product_#{product_two.id}"
        check "catalog_product_#{product_three.id}"

        click_button t('workarea.admin.catalog_products.index.edit_each')

        assert(page.has_content?(t('workarea.admin.bulk_action_sequential_product_edits.publishing.title')))
        click_button "#{t('workarea.admin.bulk_action_sequential_product_edits.publishing.make_changes')} →"

        assert(page.has_content?('Foo A'))
        assert(page.has_content?(t('workarea.admin.bulk_action_sequential_product_edits.workflow_bar.editing_with_count', current: 1, total: 3)))
        click_link "#{t('workarea.admin.bulk_action_sequential_product_edits.product.next')} →"
        assert(page.has_content?('Foo B'))
        assert(page.has_content?(t('workarea.admin.bulk_action_sequential_product_edits.workflow_bar.editing_with_count', current: 2, total: 3)))
        click_link "#{t('workarea.admin.bulk_action_sequential_product_edits.product.next')} →"
        assert(page.has_content?('Foo C'))
        assert(page.has_content?(t('workarea.admin.bulk_action_sequential_product_edits.workflow_bar.editing_with_count', current: 3, total: 3)))
        click_link "← #{t('workarea.admin.bulk_action_sequential_product_edits.product.previous')}"
        assert(page.has_content?('Foo B'))
        assert(page.has_content?(t('workarea.admin.bulk_action_sequential_product_edits.workflow_bar.editing_with_count', current: 2, total: 3)))
        click_link "← #{t('workarea.admin.bulk_action_sequential_product_edits.product.previous')}"
        assert(page.has_content?('Foo A'))
        assert(page.has_content?(t('workarea.admin.bulk_action_sequential_product_edits.workflow_bar.editing_with_count', current: 1, total: 3)))

        fill_in 'product[name]', with: 'Foo'
        click_button "#{t('workarea.admin.bulk_action_sequential_product_edits.product.save_and_continue')} →"
        assert(page.has_content?('Success'))

        assert(page.has_content?('Foo B'))
        fill_in 'product[name]', with: 'Foo'
        click_button "#{t('workarea.admin.bulk_action_sequential_product_edits.product.save_and_continue')} →"
        assert(page.has_content?('Success'))

        assert(page.has_content?('Foo C'))
        fill_in 'product[name]', with: 'Foo'
        click_button t('workarea.admin.bulk_action_sequential_product_edits.product.save_and_finish')
        assert(page.has_content?('Success'))
        assert_current_path(admin.catalog_products_path)
      end
    end
  end
end
