require 'test_helper'

module Workarea
  module Admin
    class PricingSkuPricesSystemTest < SystemTest
      include Admin::IntegrationTest
      setup :set_pricing_sku

      def set_pricing_sku
        @sku = create_pricing_sku(
          prices: [
            { regular: 11, sale: 9.99, min_quantity: 1 },
            { regular: 5, sale: 3, min_quantity: 7 }
          ])
      end

      def test_creates_price
        visit admin.pricing_sku_prices_path(@sku)
        click_link t('workarea.admin.prices.index.button')
        fill_in 'price[regular]', with: '10.00'
        fill_in 'price[sale]', with: '3.95'
        fill_in 'price[min_quantity]', with: '2'

        click_button t('workarea.admin.prices.new.create_price')
        assert(page.has_content?('Success'))

        row = find_all("table tr")[3]
        within(row) do
          assert(page.has_content?('10.00'))
          assert(page.has_content?('3.95'))
          assert(page.has_content?('2'))
          assert(page.has_content?(t('workarea.admin.prices.active')))
          assert(page.has_content?(t('workarea.admin.pricing_skus.not_on_sale')))
        end
      end

      def test_updates_price
        visit admin.pricing_sku_prices_path(@sku)
        click_on(t('workarea.admin.actions.edit'), match: :first)

        fill_in 'price[regular]', with: '10.00'
        fill_in 'price[sale]', with: '3.95'
        fill_in 'price[min_quantity]', with: '3'
        find('.toggle-button__label--positive').click
        click_button t('workarea.admin.form.save_changes')

        assert(page.has_content?('Success'))

        row = find_all("table tr")[1]
        within(row) do
          assert(page.has_content?('10.00'))
          assert(page.has_content?('3.95'))
          assert(page.has_content?('3'))
          assert(page.has_content?(t('workarea.admin.prices.inactive')))
          assert(page.has_content?(t('workarea.admin.pricing_skus.on_sale')))
        end
      end

      def test_destroys_price
        visit admin.pricing_sku_prices_path(@sku)

        row = find_all("table tr")[1]
        within(row) do
          assert(page.has_content?('11.00'))
          assert(page.has_content?('9.99'))
          assert(page.has_content?('1'))
        end

        click_on(t('workarea.admin.actions.delete'), match: :first)
        assert(page.has_content?('Success'))

        row = find_all("table tr")[1]
        within(row) do
          refute_text('11.00')
          refute_text('9.99')
          refute_text('1')
        end
      end
    end
  end
end
