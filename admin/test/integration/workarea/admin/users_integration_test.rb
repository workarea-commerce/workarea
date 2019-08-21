require 'test_helper'

module Workarea
  module Admin
    class UsersIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_searching_users
        current_admin = create_user(first_name: 'Jane', super_admin: true)
        set_current_user(current_admin)

        create_user(first_name: 'Janet', admin: true)
        create_user(first_name: 'Janice', admin: true)

        get admin.users_path(q: 'Jan', format: :json), xhr: true

        results = JSON.parse(response.body)['results']
        assert_equal(3, results.size)
        assert_includes(results.map { |u| u['value'] }, current_admin.id.to_s)

        get admin.users_path(q: 'Jan', format: :json, exclude_current_user: true), xhr: true

        results = JSON.parse(response.body)['results']
        assert_equal(2, results.size)
        refute_includes(results.map { |u| u['value'] }, current_admin.id.to_s)
      end

      def test_updates_a_user
        user = create_user

        patch admin.user_path(user),
          params: {
            user: {
              email: 'test@workarea.com',
              password: 'W3bl1nc!',
              tag_list: 'different,tags',
              admin: true,
              releases_access: true,
              store_access: true,
              catalog_access: true,
              orders_access: true,
              people_access: true,
              marketing_access: true
            }
          }

        user.reload

        assert_equal('test@workarea.com', user.email)
        assert_equal(user, user.authenticate('W3bl1nc!'))
        assert_equal(%w(different tags), user.tags)
        assert(user.admin)
        assert(user.releases_access)
        assert(user.store_access)
        assert(user.catalog_access)
        assert(user.orders_access)
        assert(user.people_access)
        assert(user.marketing_access)
      end

      def test_permissions_management
        user = create_user

        admin_user.update_attributes!(
          super_admin: false,
          admin: true,
          people_access: true,
          permissions_manager: false
        )

        get admin.permissions_user_path(user)
        assert(response.redirect?)

        patch admin.user_path(user),
          params: {
            user: {
              admin: true,
              releases_access: true,
              store_access: true,
              catalog_access: true,
              orders_access: true,
              people_access: true,
              marketing_access: true
            }
          }

        user.reload

        refute(user.admin)
        refute(user.releases_access)
        refute(user.store_access)
        refute(user.catalog_access)
        refute(user.orders_access)
        refute(user.people_access)
        refute(user.marketing_access)

        admin_user.update_attributes!(permissions_manager: true)
        get admin.permissions_user_path(create_user)
        assert(response.ok?)

        patch admin.user_path(user),
          params: {
            user: {
              admin: true,
              releases_access: true,
              store_access: true,
              catalog_access: true,
              orders_access: true,
              people_access: true,
              marketing_access: true
            }
          }

        user.reload

        assert(user.admin)
        assert(user.releases_access)
        assert(user.store_access)
        assert(user.catalog_access)
        assert(user.orders_access)
        assert(user.people_access)
        assert(user.marketing_access)
      end

      def test_authentication_token
        user = create_user(admin: true);

        old_token = user.token

        patch admin.user_path(user), params: { user: { admin: false } }

        user.reload
        refute_equal(old_token, user.token)
      end

      def test_updating_email_signup
        user = create_user

        patch admin.user_path(user),
              params: { email_signup: 'true' }

        assert(flash[:success].present?)
        assert(Email.signed_up?(user.email))

        patch admin.user_path(user),
              params: { email_signup: 'false' }

        assert(flash[:success].present?)
        refute(Email.signed_up?(user.email))
      end

      def test_password_reset
        user = create_user

        post admin.send_password_reset_user_path(user)

        assert_redirected_to(admin.user_path(user))
        assert(flash[:success].present?)

        assert_equal(1, User::PasswordReset.count)

        reset = User::PasswordReset.first
        assert_equal(user.id, reset.user_id)

        delivery = ActionMailer::Base.deliveries.last
        assert_includes(delivery.subject, t('workarea.storefront.email.password_reset.subject'))
        assert_includes(delivery.to, user.email)
        assert_includes(delivery.html_part.body, reset.token)
      end

      def test_unlock_user
        user = create_user(
          failed_login_count: Workarea.config.allowed_login_attempts + 1,
          last_login_attempt_at: Time.current
        )

        patch admin.unlock_user_path(user)

        assert_redirected_to(admin.user_path(user))
        assert(flash[:success].present?)
        refute(user.reload.login_locked?)
      end
    end
  end
end
