require 'test_helper'

module Workarea
  module Storefront
    module Users
      class AddressesIntegrationTest < Workarea::IntegrationTest
        setup :set_user
        setup :set_login

        def set_user
          @user = create_user(email: 'bcrouse@workarea.com', password: 'W3bl1nc!')
        end

        def set_login
          post storefront.login_path,
            params: { email: 'bcrouse@workarea.com', password: 'W3bl1nc!' }
        end

        def test_can_create_an_address
          post storefront.users_addresses_path,
            params: {
              address: {
                first_name: 'Ben',
                last_name: 'Crouse',
                street: '12 N. 3rd St.',
                city: 'Philadelphia',
                region: 'PA',
                country: 'US',
                postal_code: '19106',
                phone_number: '2159251800'
              }
            }

          assert_redirected_to(storefront.users_account_path)

          @user.reload
          assert_equal(1, @user.addresses.length)

          address = @user.addresses.first
          assert_equal('Ben', address.first_name)
          assert_equal('Crouse', address.last_name)
          assert_equal('12 N. 3rd St.', address.street)
          assert_equal('Philadelphia', address.city)
          assert_equal('PA', address.region)
          assert_equal(Country['US'], address.country)
          assert_equal('19106', address.postal_code)
          assert_equal('2159251800', address.phone_number)
        end

        def test_can_update_an_address
          address = @user.addresses.create!(
            first_name: 'Ben',
            last_name: 'Crouse',
            street: '22 S. 3rd St.',
            city: 'Philadelphia',
            region: 'PA',
            postal_code: '19106',
            country: 'US',
            phone_number: '2159251800'
          )

          patch storefront.users_address_path(address),
            params: {
              address: {
                first_name: 'Ben',
                last_name: 'Crouse',
                street: '12 N. 3rd St.',
                street_2: 'Second Floor',
                city: 'Philadelphia',
                region: 'PA',
                postal_code: '19106',
                country: 'US',
                phone_number: '2159251800'
              }
            }

          assert_redirected_to(storefront.users_account_path)

          address.reload
          assert_equal('12 N. 3rd St.', address.street)
          assert_equal('Second Floor', address.street_2)
        end

        def test_can_delete_an_address
          address = @user.addresses.create!(
            first_name: 'Ben',
            last_name: 'Crouse',
            street: '22 S. 3rd St.',
            city: 'Philadelphia',
            region: 'PA',
            postal_code: '19106',
            country: 'US',
            phone_number: '2159251800'
          )

          delete storefront.users_address_path(address)

          assert_redirected_to(storefront.users_account_path)

          @user.reload
          assert(@user.addresses.empty?)
        end

        def test_requires_login
          delete storefront.logout_path

          get storefront.new_users_address_path
          assert_redirected_to(storefront.login_path)

          post storefront.users_addresses_path
          assert_redirected_to(storefront.login_path)

          address = @user.addresses.create!(
            first_name: 'Ben',
            last_name: 'Crouse',
            street: '22 S. 3rd St.',
            city: 'Philadelphia',
            region: 'PA',
            postal_code: '19106',
            country: 'US',
            phone_number: '2159251800'
          )

          get storefront.edit_users_address_path(address)
          assert_redirected_to(storefront.login_path)

          patch storefront.users_address_path(address)
          assert_redirected_to(storefront.login_path)

          delete storefront.users_address_path(address)
          assert_redirected_to(storefront.login_path)
        end
      end
    end
  end
end
