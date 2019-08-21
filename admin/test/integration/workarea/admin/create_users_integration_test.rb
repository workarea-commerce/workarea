require 'test_helper'

module Workarea
  module Admin
    class CreateUsersIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_creating_an_admin
        post admin.create_users_path,
          params: {
            user: {
              admin: true,
              email: 'foo@bar.com',
              first_name: 'Ben',
              last_name: 'Crouse',
              password: 'W3bl1nc!',
              tag_list: 'foo,bar,baz',
              permissions_manager: true,
              releases_access: true,
              store_access: true,
              catalog_access: true,
              orders_access: true,
              people_access: true,
              marketing_access: true,
              created_by_id: admin_user.id
            }
          }

        user = User.find_by(email: 'foo@bar.com')

        assert_equal(user, user.authenticate('W3bl1nc!'))
        assert_equal(%w(foo bar baz), user.tags)
        assert(user.admin)
        assert(user.permissions_manager)
        assert(user.releases_access)
        assert(user.store_access)
        assert(user.catalog_access)
        assert(user.orders_access)
        assert(user.people_access)
        assert(user.marketing_access)
        assert(user.created_by_id.present?)
      end

      def test_creating_a_customer
        post admin.create_users_path,
          params: {
            user: {
              email: 'foo@bar.com',
              first_name: 'Ben',
              last_name: 'Crouse',
              password: 'Passw0rd!',
              tag_list: 'foo,bar,baz',
              created_by_id: admin_user.id
            },
            profile: {
              store_credit: '5.25'
            }
          }

        user = User.find_by(email: 'foo@bar.com')

        assert_equal(user, user.authenticate('Passw0rd!'))
        assert_equal('Ben', user.first_name)
        assert_equal('Crouse', user.last_name)
        assert_equal(%w(foo bar baz), user.tags)
        refute(user.admin)
        refute(user.permissions_manager)
        refute(user.releases_access)
        refute(user.store_access)
        refute(user.catalog_access)
        refute(user.orders_access)
        refute(user.people_access)
        refute(user.marketing_access)
        assert(user.created_by_id.present?)

        profile = Payment::Profile.lookup(PaymentReference.new(user))
        assert_equal(5.25.to_m, profile.store_credit)
      end

      def test_impersonation
        post admin.create_users_path,
          params: {
            impersonate: true,
            user: {
              admin: true,
              email: 'admin@bar.com',
              first_name: 'Ben',
              last_name: 'Crouse',
              password: 'W3bl1nc!',
              tag_list: 'foo,bar,baz',
              permissions_manager: true,
              releases_access: true,
              store_access: true,
              catalog_access: true,
              orders_access: true,
              people_access: true,
              marketing_access: true
            }
          }

        user = User.find_by(email: 'admin@bar.com')
        assert_redirected_to(admin.user_path(user))

        post admin.create_users_path,
          params: {
            impersonate: false,
            user: {
              email: 'customer1@bar.com',
              first_name: 'Ben',
              last_name: 'Crouse',
              password: 'Passw0rd!',
              tag_list: 'foo,bar,baz'
            }
          }

        user = User.find_by(email: 'customer1@bar.com')
        assert_redirected_to(admin.user_path(user))

        post admin.create_users_path,
          params: {
            impersonate: true,
            user: {
              email: 'customer2@bar.com',
              first_name: 'Ben',
              last_name: 'Crouse',
              password: 'Passw0rd!',
              tag_list: 'foo,bar,baz'
            }
          }

        # Rails bug prevents testing with the route helper methd
        assert(response.redirect?)
        assert_match(/users\/account/, response.location)
      end

      def test_creating_without_a_password
        post admin.create_users_path,
          params: {
            user: {
              email: 'foo@bar.com',
              first_name: 'Ben',
              last_name: 'Crouse',
              tag_list: 'foo,bar,baz'
            }
          }

        user = User.find_by(email: 'foo@bar.com')
        assert_equal('Ben', user.first_name)
        assert_equal('Crouse', user.last_name)
        assert_equal(%w(foo bar baz), user.tags)
      end

      def test_creating_an_admin_without_permissions_management
        admin_user.update_attributes!(
          super_admin: false,
          admin: true,
          people_access: true,
          permissions_manager: false
        )

        get admin.create_users_path
        assert_redirected_to(admin.new_create_user_path)
      end

      def test_sending_email
        pass && (return) unless Workarea.config.send_transactional_emails

        post admin.create_users_path,
          params: {
            send_account_creation_email: false,
            user: { email: 'foo@bar.com' }
          }

        assert(ActionMailer::Base.deliveries.empty?)

        post admin.create_users_path,
          params: {
            send_account_creation_email: true,
            user: { email: 'qux@bar.com' }
          }

        assert_equal(1, ActionMailer::Base.deliveries.size)
        email = ActionMailer::Base.deliveries.last
        assert(email.to.include?('qux@bar.com'))
      end
    end
  end
end
