require 'test_helper'

module Workarea
  module Admin
    class ActivitySystemTest < SystemTest
      include Admin::IntegrationTest

      def test_shows_a_filterable_list_of_activity_in_the_admin
        visit admin.create_catalog_products_path
        fill_in 'product[name]', with: 'Testing Product'
        click_button 'save_setup'

        visit admin.create_releases_path
        fill_in 'release[name]', with: 'Foo'
        click_button 'save_setup'

        visit admin.activity_path
        assert(page.has_content?('Ben Crouse'))
        assert(
          page.has_content?(
            t(
              'workarea.admin.activities.catalog_product_create_html',
              name: 'Testing Product'
            )
          )
        )
        assert(
          page.has_content?(
            t(
              'workarea.admin.activities.release_create_html',
              name: 'Foo'
            )
          )
        )
        select 'release', from: 'type'
        page.execute_script("$('#activity_form').submit()") # because autosubmit control

        assert(
          page.has_no_content?(
            t(
              'workarea.admin.activities.catalog_product_create_html',
              name: 'Testing Product'
            )
          )
        )
        assert(page.has_content?('Ben Crouse'))
        assert(
          page.has_content?(
            t(
              'workarea.admin.activities.release_create_html',
              name: 'Foo'
            )
          )
        )
      end

      def test_activity_log_for_releases
        product = create_product
        release = create_release

        visit admin.release_releasables_path(release)

        click_link product.name
        click_link t('workarea.admin.cards.attributes.title')
        find('#product_active_false_label').click
        click_button t('workarea.admin.form.save_changes')

        visit admin.release_path(release)

        click_button t('workarea.admin.releases.show.publish_now')

        visit admin.activity_path

        change = t('workarea.admin.activities.change', count: 1)
        assert(page.has_content?(t('workarea.admin.activities.release_published_html', change: change, name: release.name)))
      end
    end
  end
end
