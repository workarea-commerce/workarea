require 'test_helper'

module Workarea
  module Storefront
    class AddressesSystemTest < Workarea::SystemTest
      setup :set_user

      def set_user
        create_user(
          email: 'bcrouse@workarea.com',
          password: 'W3bl1nc!'
        )
      end

      def test_managing_addresses
        visit storefront.login_path

        within '#login_form' do
          fill_in 'email', with: 'bcrouse@workarea.com'
          fill_in 'password', with: 'W3bl1nc!'
          click_button t('workarea.storefront.users.login')
        end

        visit storefront.users_account_path

        click_link t('workarea.storefront.users.add_address')

        within '#address_form' do
          fill_in 'address[first_name]',   with: 'Ben'
          fill_in 'address[last_name]',    with: 'Crouse'
          fill_in 'address[street]',       with: '12 N. 3rd St.'
          fill_in 'address[city]',         with: 'Philadelphia'
          select 'Pennsylvania', from: 'address_region_select'
          fill_in 'address[postal_code]',  with: '19106'
          fill_in 'address[phone_number]', with: '2159251800'
          click_button t('workarea.storefront.forms.save')
        end

        assert(page.has_content?('Success'))
        assert(page.has_content?('12 N. 3rd St.'))

        click_link t('workarea.storefront.forms.edit')

        within '#address_form' do
          fill_in 'address[street]', with: '22 S. 3rd St.'
          fill_in 'address[street_2]', with: 'Second Floor'
          fill_in 'address[phone_number]', with: '5556667777'
          click_button t('workarea.storefront.forms.save')
        end

        assert(page.has_content?('Success'))
        assert(page.has_content?('22 S. 3rd St.'))
        assert(page.has_content?('Second Floor'))

        click_button t('workarea.storefront.forms.delete')
        assert(page.has_no_content?('22 S. 3rd St.'))
      end
    end
  end
end
