require 'test_helper'

module Workarea
  module Admin
    class PricingSkusSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_management
        visit admin.pricing_skus_path
        click_link t('workarea.admin.pricing_skus.index.button')

        fill_in 'sku[id]', with: 'SKU1'
        click_button 'create_sku'

        assert(page.has_content?('Success'))
        assert(page.has_content?('SKU1'))

        click_link t('workarea.admin.cards.attributes.title')
        fill_in 'sku[tax_code]', with: '002'
        click_button 'save_sku'

        assert(page.has_content?('Success'))
        assert(page.has_content?('002'))
      end

      def test_prices
        visit admin.pricing_skus_path
        click_link t('workarea.admin.pricing_skus.index.button')

        fill_in 'sku[id]', with: 'SKU1'
        click_button 'create_sku'
        assert(page.has_content?('Success'))

        click_link t('workarea.admin.prices.label')
        click_link t('workarea.admin.prices.index.button')
        fill_in 'price[regular]', with: '10.00'
        click_button 'create_price'

        assert(page.has_content?('Success'))
        assert(page.has_content?("#{Money.default_currency.symbol}10.00"))

        click_link t('workarea.admin.actions.edit')
        fill_in 'price[regular]', with: '9.99'
        click_button 'save_price'

        assert(page.has_content?('Success'))
        assert(page.has_content?("#{Money.default_currency.symbol}9.99"))

        click_link t('workarea.admin.actions.delete')

        assert(page.has_content?('Success'))
        assert(page.has_no_content?("#{Money.default_currency.symbol}9.99"))
      end
    end
  end
end
