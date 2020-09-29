require 'test_helper'

module Workarea
  module Storefront
    class CreditCardsSystemTest < Workarea::SystemTest
      setup :set_user
      setup :set_year

      def set_user
        @user = create_user(email: 'bcrouse@workarea.com', password: 'W3bl1nc!')
      end

      def set_year
        @year = (Time.current.year + 1).to_s
      end

      def test_managing_credit_cards
        visit storefront.login_path

        within '#login_form' do
          fill_in 'email', with: 'bcrouse@workarea.com'
          fill_in 'password', with: 'W3bl1nc!'
          click_button t('workarea.storefront.users.login')
        end

        visit storefront.new_users_credit_card_path

        within '#credit_card_form' do
          fill_in 'credit_card[number]', with: '4111111111111111'
          fill_in 'credit_card[first_name]', with: 'Ben'
          fill_in 'credit_card[last_name]', with: 'Crouse'
          select '1', from: 'credit_card[month]'
          select @year, from: 'credit_card[year]'
          fill_in 'credit_card[cvv]', with: '999'
          click_button t('workarea.storefront.forms.save')
        end

        assert(page.has_content?('Success'))
        assert(page.has_content?('ending in 1111'))
        assert(page.has_content?('1'))
        assert(page.has_content?(@year))

        click_link t('workarea.storefront.forms.edit')

        within '#credit_card_form' do
          select '2', from: 'credit_card[month]'
          fill_in 'credit_card[cvv]', with: '999'
          click_button t('workarea.storefront.forms.save')
        end

        assert(page.has_content?('Success'))
        assert(page.has_content?('ending in 1111'))
        assert(page.has_content?('2'))
        assert(page.has_content?(@year))

        click_button t('workarea.storefront.forms.delete')

        assert(page.has_no_content?('ending in 1111'))

        visit storefront.new_users_credit_card_path

        within '#credit_card_form' do
          fill_in 'credit_card[number]', with: '4012000033330422'
          fill_in 'credit_card[first_name]', with: 'Ben'
          fill_in 'credit_card[last_name]', with: 'Crouse'
          select '1', from: 'credit_card[month]'
          select @year, from: 'credit_card[year]'
          fill_in 'credit_card[cvv]', with: '999'
          click_button t('workarea.storefront.forms.save')
        end

        refute_text('Success')
        assert(page.has_content?(I18n.t('workarea.payment.store_credit_card_failure')))
      end
    end
  end
end
