require 'test_helper'

module Workarea
  module Admin
    class TimelineSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_timeline
        visit admin.catalog_categories_path

        click_link 'Add New Category'
        fill_in 'category[name]', with: 'Test Category'
        click_button 'save_setup'

        click_link 'or skip this'
        click_link 'Continue to Taxonomy'
        click_button 'Save and Continue'
        click_button 'Save and Continue'
        click_button 'Save and Finish'

        assert(page.has_content?('Ben Crouse'))
        assert(
          page.has_content?(
            t(
              'workarea.admin.activities.catalog_category_create_html',
              name: 'Test Category'
            )
          )
        )
        click_link 'Timeline'

        assert(page.has_content?('Ben Crouse'))
        assert(
          page.has_content?(
            t(
              'workarea.admin.activities.catalog_category_create_html',
              name: 'Test Category'
            )
          )
        )
        click_link 'Test Category', match: :first
        click_link 'Attributes'

        visit admin.create_releases_path
        fill_in 'release[name]', with: 'Fall Release'
        click_button 'save_setup'

        visit admin.catalog_categories_path
        click_link 'Test Category'
        click_link 'Attributes'

        select 'Fall Release', from: 'release_id'
        fill_in 'category[name]', with: 'Edited Category'
        click_button 'save_category'

        select 'the live site', from: 'release_id'
        click_link 'Timeline'
        assert(page.has_content?('Fall Release'))
      end
    end
  end
end
