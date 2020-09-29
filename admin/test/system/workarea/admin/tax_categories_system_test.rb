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

      def test_managing_tax_rates
        category = create_tax_category(
          name: 'Test Category',
          code: '002',
          rates: []
        )

        visit admin.tax_categories_path

        click_link 'Test Category'
        within '.card--rates' do # wait for turbolinks
          click_link t('workarea.admin.tax_categories.cards.rates.title')
        end

        assert(page.has_content?(t('workarea.admin.tax_rates.index.empty_message')))

        #
        # New rate
        #
        click_link t('workarea.admin.tax_rates.index.new_button')

        fill_in 'rate[country]', with: 'US'
        fill_in 'rate[region]', with: 'PA'
        fill_in 'rate[postal_code]', with: '19106'

        fill_in 'rate[country_percentage]', with: 2
        fill_in 'rate[region_percentage]', with: 4
        fill_in 'rate[postal_code_percentage]', with: 6

        fill_in 'rate[tier_min]', with: 5
        fill_in 'rate[tier_max]', with: 500

        find('.toggle-button__label--positive').click

        click_button t('workarea.admin.tax_rates.new.create_button')

        assert(page.has_content?('Success'))

        #
        # Rates Index
        #
        within '.index-table__row' do
          assert(page.has_content?('US'))
          assert(page.has_content?('PA'))
          assert(page.has_content?('19106'))

          assert(page.has_content?('6%'))
          assert(page.has_content?('4%'))
          assert(page.has_content?('2%'))

          assert(page.has_content?("#{Money.default_currency.symbol}5.00"))
          assert(page.has_content?("#{Money.default_currency.symbol}500.00"))

          assert(page.has_content?(t('workarea.admin.false')))
        end

        #
        # Edit
        #
        within '.index-table__row' do
          click_link t('workarea.admin.actions.edit')
        end

        fill_in 'rate[country_percentage]', with: 0.005
        fill_in 'rate[region_percentage]', with: 10
        fill_in 'rate[postal_code_percentage]', with: 20.5

        click_button t('workarea.admin.tax_rates.edit.save_button')

        assert(page.has_content?('Success'))

        within '.index-table__row' do
          assert(page.has_content?('0.005%'))
          assert(page.has_content?('10%'))
          assert(page.has_content?('20.5%'))
        end

        #
        # Delete
        #
        within '.index-table__row' do
          click_link t('workarea.admin.actions.delete')
        end

        assert(page.has_content?('Success'))
        assert_current_path(admin.tax_category_rates_path(category))
        assert(page.has_content?(t('workarea.admin.tax_rates.index.empty_message')))
      end

      def test_sorting_rates
        category = create_tax_category(
          name: 'Test Category',
          code: '003',
          rates: [
            { country: 'CA', region: 'Qux', postal_code: '10000' },
            { country: 'US', region: 'Corge', postal_code: '20000' },
            { country: 'AL', region: 'Grault', postal_code: '30000' }
          ]
        )

        visit admin.tax_category_rates_path(category)

        select(t('workarea.sorts.country', from: 'sort'))
        assert(page.has_ordered_text?('AL', 'CA', 'US'))

        select(t('workarea.sorts.region', from: 'sort'))
        assert(page.has_ordered_text?('Corge', 'Grault', 'Qux'))

        select(t('workarea.sorts.postal_code', from: 'sort'))
        assert(page.has_ordered_text?('10000', '20000', '30000'))
      end

      def test_searching_rates
        category = create_tax_category(
          name: 'Test Category',
          code: '004',
          rates: [
            { country: 'US', region: 'PA', postal_code: '19000' },
            { country: 'US', region: 'NE Philly', postal_code: '19123' },
            { country: 'RU', region: 'Siberia', postal_code: '00019' }
          ]
        )

        visit admin.tax_category_rates_path(category)

        within '.index-table' do
          assert_match(/US.*PA.*19000/, page.text)
          assert_match(/US.*NE Philly.*19123/, page.text)
          assert_match(/RU.*Siberia.*00019/, page.text)
        end

        within '#rates_search_form' do
          select(t('workarea.sorts.postal_code'), from: 'sort')
        end

        within '.index-table' do
          assert(page.has_ordered_text?('Siberia', 'PA', 'NE Philly'))
        end

        within '#rates_search_form' do
          fill_in 'search_rates', with: '19'
          click_button 'search_rates'
        end

        within '.index-table' do
          assert_match(/US.*PA.*19000/, page.text)
          assert_match(/US.*NE Philly.*19123/, page.text)
          refute_match(/RU.*Siberia.*00019/, page.text)
        end

        within '#rates_search_form' do
          fill_in 'search_rates', with: 'NE P'
          click_button 'search_rates'
        end

        within '.index-table' do
          refute_match(/US.*PA.*19000/, page.text)
          assert_match(/US.*NE Philly.*19123/, page.text)
          refute_match(/RU.*Siberia.*00019/, page.text)
        end

        within '#rates_search_form' do
          fill_in 'search_rates', with: 'ru'
          click_button 'search_rates'
        end

        within '.index-table' do
          refute_match(/US.*PA.*19000/, page.text)
          refute_match(/US.*NE Philly.*19123/, page.text)
          assert_match(/RU.*Siberia.*00019/, page.text)
        end

        within '#rates_search_form' do
          fill_in 'search_rates', with: 'Foo'
          click_button 'search_rates'
        end

        assert(page.has_content?(t('workarea.admin.tax_rates.index.empty_message')))
      end
    end
  end
end
