require 'test_helper'

module Workarea
  module Admin
    class DiscountsSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_managing_discounts
        create_product(name: 'Foo')

        visit admin.pricing_discounts_path

        click_link 'add_discount'
        choose 'type_product'
        click_button 'save_setup'

        fill_in 'discount[name]', with: 'Test Discount'
        click_button 'save_details'

        fill_in 'discount[amount]', with: 5
        find('.discount__node-group .select2-selection--multiple').click
        assert(page.has_content?('Foo'))
        find('.select2-results__option', text: 'Foo').click

        click_button 'save_rules'
        assert(page.has_content?('Success'))

        click_button 'publish'
        assert(page.has_content?('Success'))

        visit admin.pricing_discounts_path
        assert(page.has_content?('Test Discount'))
        click_link 'Test Discount'
        assert(page.has_content?('Test Discount'))
        click_link 'Attributes'
        fill_in 'discount[name]', with: 'Edit Test Discount'

        click_button 'save_discount'
        assert(page.has_content?('Success'))
        assert(page.has_content?('Edit Test Discount'))

        click_link 'Rules'
        # From list builder selection
        assert(page.has_content?('Foo'))

        click_link 'Edit Test Discount'
        click_link t('workarea.admin.actions.delete')
        assert_current_path(admin.pricing_discounts_path)
        assert(page.has_no_content?('Test Discount'))
      end

      def test_generating_promo_codes
        visit admin.pricing_discount_code_lists_path

        click_link 'add_promo_code_list'
        fill_in 'code_list[name]',  with: 'Test Code List'
        fill_in 'code_list[count]', with: 5
        click_button 'create_code_list'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Test Code List'))

        visit admin.pricing_discount_code_lists_path
        click_link 'Test Code List'

        click_link t('workarea.admin.cards.attributes.title')
        fill_in 'code_list[name]', with: 'Renamed Code List'
        click_button 'update_code_list'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Renamed Code List'))
        assert(page.has_no_content?('Test Code List'))

        click_link t('workarea.admin.actions.delete')

        visit admin.pricing_discount_code_lists_path
        assert(page.has_no_content?('Test Code List'))
        assert(page.has_no_content?('Renamed Code List'))
      end

      def test_insights
        discount = create_category_discount

        Metrics::DiscountByDay.inc(
          key: { discount_id: discount.id },
          at: Time.zone.local(2018, 10, 27),
          discounts: -333.to_m,
          orders: 444,
          revenue: 555.to_m
        )

        travel_to Time.zone.local(2018, 10, 30)

        visit admin.pricing_discount_path(discount)
        assert(page.has_content?('333'))
        assert(page.has_content?('444'))
        assert(page.has_content?('555'))

        click_link t('workarea.admin.pricing_discounts.cards.insights.title')
        assert(page.has_content?('333'))
        assert(page.has_content?('444'))
        assert(page.has_content?('555'))
      end

      def test_discount_redemptions
        discount = create_category_discount
        7.times { |i| discount.log_redemption("foo-#{i}@workarea.com") }
        order = create_placed_order(email: 'foo-1@workarea.com')

        visit admin.pricing_discount_path(discount)
        within '.card--redemptions' do
          assert(page.has_content?(7))
        end

        click_link t('workarea.admin.pricing_discounts.cards.redemptions.header')
        assert(page.has_content?(7))
        7.times { |i| assert(page.has_content?("foo-#{i}@workarea.com")) }

        click_link 'foo-1@workarea.com'
        assert(page.has_content?(order.id))
      end
    end
  end
end
