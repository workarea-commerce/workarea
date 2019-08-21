require 'test_helper'

module Workarea
  module Search
    class Admin
      class UserTest < TestCase
        setup :set_user

        def set_user
          @user = create_user
        end

        def test_includes_role_text
          @user.update_attributes!(admin: true)
          assert_includes(User.new(@user).search_text, 'admin')
          assert_includes(User.new(@user).search_text, 'administrator')

          @user.update_attributes!(admin: false)
          assert_includes(User.new(@user).search_text, 'customer')
        end

        def test_includes_user_address_text
          @user.addresses.create!(
            first_name: 'Ben',
            last_name: 'Crouse',
            street: '12 N. 3rd St.',
            city: 'Philadelphia',
            region: 'PA',
            country: 'US',
            postal_code: '19106',
            phone_number: '2159251800'
          )

          result = User.new(@user).search_text

          assert_includes(result, 'Ben')
          assert_includes(result, 'Crouse')
          assert_includes(result, '12 N. 3rd St.')
          assert_includes(result, 'Philadelphia')
          assert_includes(result, 'PA')
          assert_includes(result, 'US')
          assert_includes(result, '19106')
          assert_includes(result, '2159251800')
        end

        def test_not_indexing_system_users
          assert(User.new(@user).should_be_indexed?)
          refute(User.new(Workarea::User.console).should_be_indexed?)
        end
      end
    end
  end
end
