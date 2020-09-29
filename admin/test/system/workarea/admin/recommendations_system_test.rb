require 'test_helper'

module Workarea
  module Admin
    class RecommendationsSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_managing_recommendations
        product = create_product(name: 'First')
        product_2 = create_product(name: 'Second')
        product_3 = create_product(name: 'Third')

        #
        # Add custom products
        #

        visit admin.catalog_product_path(product)
        click_link 'Recommendations'
        find('.select2-selection').click
        find('.select2-results__option', text: product_2.name).click
        find('.select2-selection').click
        find('.select2-results__option', text: product_3.name).click
        click_button 'Save'

        assert_current_path(admin.catalog_product_path(product))
        assert(page.has_content?('Success'))

        #
        # Sort custom products
        #

        visit storefront.product_path(product)
        assert(page.has_ordered_text?('Second', 'Third'))

        visit admin.catalog_product_path(product)
        click_link 'Recommendations'

        select_2_choices = all('.select2-selection__choice')
        select_2_choices[0].drag_to select_2_choices[1]
        click_button 'Save'

        assert_current_path(admin.catalog_product_path(product))
        assert(page.has_content?('Success'))

        visit admin.catalog_product_path(product)
        click_link 'Recommendations'
        assert(page.has_ordered_text?('Third', 'Second'))

        visit storefront.product_path(product)
        assert(page.has_ordered_text?('Third', 'Second'))
        #
        # Remove custom products
        #
        visit admin.catalog_product_path(product)
        click_link 'Recommendations'

        click_link 'Recommendations'
        assert(page.has_selector?("option[value='#{product_2.id}']"))
        assert(page.has_selector?("option[value='#{product_3.id}']"))
        all('.select2-selection__choice__remove').first.click
        all('.select2-selection__choice__remove').last.click
        click_button 'Save'

        assert_current_path(admin.catalog_product_path(product))
        assert(page.has_content?('Success'))

        click_link 'Recommendations'
        refute_selector("option[value='#{product_2.id}']")
        refute_selector("option[value='#{product_3.id}']")
        assert(page.has_ordered_text?('Custom', 'Similar Products', 'Also Purchased'))

        #
        # Re-order sources
        #

        assert(page.has_selector?('.ui-sortable'))
      end
    end
  end
end
