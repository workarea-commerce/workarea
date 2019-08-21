require 'test_helper'

module Workarea
  module Admin
    class TaxCategoriesSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_managing_tax_categories
        visit admin.tax_categories_path

        click_link 'add_tax_category'
        fill_in 'category[name]', with: 'Testing Tax Category'
        fill_in 'category[code]', with: '001'
        click_button 'create_tax_category'

        click_link t('workarea.admin.cards.attributes.title')

        fill_in 'category[name]', with: 'Edited Tax Category'
        click_button 'save_tax_category'

        visit admin.tax_categories_path
        assert(page.has_content?('Edited Tax Category'))

        click_link 'Edited Tax Category'
        click_link t('workarea.admin.actions.delete')

        visit admin.tax_categories_path
        assert(page.has_no_content?('Edited Tax Category'))
      end

      def test_viewing_existing_tax_rates
        create_tax_category(
          name: 'Test Category',
          code: '002',
          rates: [
            {
              percentage: 0.06,
              tier_min: 100.to_m,
              region: 'PA',
              country: 'US',
              postal_code: '19106'
            }
          ]
        )

        visit admin.tax_categories_path

        click_link 'Test Category'
        within '.card--rates' do # wait for turbolinks
          click_link t('workarea.admin.tax_categories.cards.rates.title')
        end

        assert(page.has_content?('6.0%'))
        assert(page.has_content?("#{Money.default_currency.symbol}100.00"))
        assert(page.has_content?('PA'))
        assert(page.has_content?('US'))
        assert(page.has_content?('19106'))
      end
    end
  end
end
