require 'test_helper'

module Workarea
  class UserTest < TestCase
    def test_admins_scope_includes_admins_of_either_type
      customer = create_user
      admin_1 = create_user(admin: true)
      admin_2 = create_user(super_admin: true)


      results = User.admins.map(&:id)
      assert_equal(2, results.count)
      assert_includes(results, admin_1.id)
      assert_includes(results, admin_2.id)
      refute_includes(results, customer.id)
    end

    def test_find_admin
      user = create_user(admin: false)
      assert_nil(User.find_admin(user.id))

      user.update_attributes!(admin: true)
      assert_equal(user, User.find_admin(user.id))

      user.update_attributes!(super_admin: true)
      assert_equal(user, User.find_admin(user.id))
    end

    def test_sets_created_at_when_another_user_has_login_success_called
      user_1 = create_user
      user_1.login_success!

      user_2 = create_user

      assert(user_2.created_at.present?)
    end

    def test_should_not_allow_a_duplicate_user_on_the_same_site
      user = create_user
      dup_user = User.new(email: user.email)

      refute(dup_user.valid?)
      assert(dup_user.errors[:email].present?)
    end

    def test_allows_a_normal_user_to_reuse_the_same_password
      user = create_user
      assert(user.update_attributes(password: 'Password1!'))
      assert_equal(user, user.authenticate('Password1!'))

      assert(user.update_attributes(password: 'Password2!'))
      assert_equal(user, user.authenticate('Password2!'))

      assert(user.update_attributes(password: 'Password1!'))
      assert_equal(user, user.authenticate('Password1!'))
    end

    def test_does_not_allow_admins_to_reuse_the_same_password
      user = create_user(admin: true)

      assert(user.update_attributes(password: 'Password1!'))
      assert_equal(user, user.authenticate('Password1!'))

      assert(user.update_attributes(password: 'Password2!'))
      assert_equal(user, user.authenticate('Password2!'))

      refute(user.update_attributes(password: 'Password1!'))
    end

    def test_find_for_login
      user = create_user(email: 'bcrouse@workarea.com', password: 'W3bl1nc!')

      assert_equal(user, User.find_for_login('bcrouse@workarea.com', 'W3bl1nc!'))
      assert_equal(user, User.find_for_login('BcRoUsE@workarea.com', 'W3bl1nc!'))
      assert_nil(User.find_for_login('fake_email_address@workarea.com', 'W3bl1nc!'))
      assert_nil(User.find_for_login('bcrouse@workarea.com', 'password'))
      assert_nil(User.find_for_login('crouse@workarea.co', 'W3bl1nc!'))
    end

    def test_password_digest_is_secure
      user = create_user(password: 'T3st_password!')
      refute_equal('T3st_password!', user.password_digest)
    end

    def test_public_info
      user = create_user(
        first_name: 'Ben',
        last_name: 'Crouse',
        email: 'bcrouse@workarea.com'
      )

      assert_equal('BC', user.public_info)

      user.addresses.create!(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      assert_equal('BC from Philadelphia', user.public_info)
    end

    def test_default_billing_address
      user = create_user
      addresses = [User::SavedAddress.new, User::SavedAddress.new]
      user.addresses = addresses

      addresses.first.last_billed_at = Time.current - 1.month
      addresses.second.last_billed_at = Time.current

      assert_equal(addresses.second, user.default_billing_address)
    end

    def test_default_shipping_address
      user = create_user
      addresses = [User::SavedAddress.new, User::SavedAddress.new]
      user.addresses = addresses

      addresses.first.last_shipped_at = Time.current - 1.month
      addresses.second.last_shipped_at = Time.current

      assert_equal(addresses.second, user.default_shipping_address)
    end

    def test_auto_save_shipping_address
      user = create_user
      user.addresses.create!(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      user.auto_save_shipping_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      assert_equal(1, user.addresses.length)
      assert(user.addresses.first.last_shipped_at.present?)
    end

    def test_auto_save_billing_address
      user = create_user
      user.addresses.create!(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      user.auto_save_billing_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      assert_equal(1, user.addresses.length)
      assert(user.addresses.first.last_billed_at.present?)
    end

    def test_login_locked
      user = create_user

      Workarea.config.allowed_login_attempts.times { user.login_failure! }
      assert(user.login_locked?)

      user.last_login_attempt_at = Time.current - (Workarea.config.lockout_period + 1.hour)
      refute(user.login_locked?)

      user.login_failure!
      user.login_success!
      assert_equal(0, user.failed_login_count)
    end

    def test_force_password_change
      user = create_user
      expired_at = Time.current - (Workarea.config.password_lifetime + 1.day)

      user.password_changed_at = expired_at

      user.admin = false
      refute(user.force_password_change?)

      user.admin = true
      assert(user.force_password_change?)

      user.password_changed_at = Time.current
      refute(user.force_password_change?)
    end


    def assert_valid_logged_in_request
      user = create_user
      request = ActionDispatch::TestRequest.create

      assert(user.valid_logged_in_request?(request))

      user.ip_address = '127.0.0.1'
      refute(user.valid_logged_in_request?(request))

      user.ip_address = '0.0.0.0'
      assert(user.valid_logged_in_request?(request))

      user.user_agent = 'Safari'
      refute(user.valid_logged_in_request?(request))

      user.user_agent = 'Rails Testing'
      assert(user.valid_logged_in_request?(request))
    end

    def test_admin
      refute(create_user.admin?)
      assert(create_user(admin: true).admin?)
      assert(create_user(super_admin: true).admin?)
    end

    def test_help_admin
      refute(create_user.help_admin?)
      refute(create_user(admin: true).help_admin?)
      assert(create_user(admin: true, help_admin: true).help_admin?)
      assert(create_user(super_admin: true).help_admin?)
    end

    def test_permissions_manager
      refute(create_user.permissions_manager?)
      refute(create_user(admin: true).permissions_manager?)
      assert(create_user(admin: true, permissions_manager: true).permissions_manager?)
      assert(create_user(super_admin: true).permissions_manager?)
    end

    def test_can_publish_now
      refute(create_user.can_publish_now?)
      assert(create_user(admin: true).can_publish_now?)
      refute(create_user(admin: true, can_publish_now: false).can_publish_now?)
      assert(create_user(super_admin: true, can_publish_now: false).can_publish_now?)
    end

    def test_can_restore
      refute(create_user.can_restore?)
      assert(create_user(admin: true).can_restore?)
      refute(create_user(admin: true, can_restore: false).can_restore?)
      assert(create_user(super_admin: true, can_restore: false).can_restore?)
    end

    def test_initials
      assert_equal('b', User.new(email: 'bcrouse@workarea.com').initials)

      user = User.new(first_name: 'Ben', last_name: 'Crouse')
      assert_equal('BC', user.initials)
    end

    def test_admins_have_more_advanced_password_requirements
      Workarea.config.password_strength = :weak

      user = User.new(admin: false, password: 'password').tap(&:valid?)
      assert(user.errors[:password].blank?)

      user = User.new(admin: true, password: 'password').tap(&:valid?)
      assert(user.errors[:password].present?)

      user = User.new(admin: true, password: 'xykrDQXT]9Ai7XEXfe').tap(&:valid?)
      assert(user.errors[:password].blank?)
    end

    def test_admin_permissions_revoked_when_no_longer_admin
      user = create_user(admin: true, releases_access: true)
      user.update_attributes!(admin: false)
      refute(user.releases_access?)

      user = create_user(super_admin: true, releases_access: true)
      user.update!(super_admin: false)
      refute(user.admin?)
      refute(user.releases_access?)
    end

    def test_status_email_recipients_only_admins
      create_user(admin: false, status_email_recipient: true)
      admin = create_user(admin: true, status_email_recipient: true)

      status_email_recipients = User.status_email_recipients
      assert_equal(1, status_email_recipients.size)
      assert_equal(admin, status_email_recipients.first)
    end
  end
end
