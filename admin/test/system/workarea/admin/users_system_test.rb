require 'test_helper'

module Workarea
  module Admin
    class UsersSystemTest < SystemTest
      include Admin::IntegrationTest

      setup :setup_user

      def setup_user
        @user = create_user(email: 'bcrouse-test@workarea.com')
        @user.addresses.create!(
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
      end

      def test_searching_for_regular_and_admin_users
        create_user(email: 'bcrouse-admin@workarea.com', admin: true)

        visit admin.users_path

        within '#user_search_form' do
          fill_in 'q', with: 'bcrouse'
          click_button 'search_users', match: :first
        end

        assert(page.has_content?('bcrouse-admin@workarea.com'))
        assert(page.has_content?('bcrouse-test@workarea.com'))
      end

      def test_creating_a_customer
        visit admin.users_path
        click_link t('workarea.admin.users.index.add_new')

        assert_current_path(admin.create_users_path)
        assert(page.has_content?(t('workarea.admin.create_users.index.title')))
        choose t('workarea.admin.create_users.index.create_a_customer')
        click_button "#{t('workarea.admin.create_users.index.continue')} →"

        assert_current_path(/#{admin.new_create_user_path}/)
        assert(page.has_content?(t('workarea.admin.create_users.customer.title')))
        fill_in 'user[email]', with: 'customer-test@workarea.com'
        fill_in 'user[password]', with: 'P@ssw0rd'
        find('#impersonate_true_label').click
        click_button t('workarea.admin.create_users.customer.create_customer')

        assert_current_path(storefront.users_account_path)
      end

      def test_creating_an_admin
        visit admin.users_path
        click_link t('workarea.admin.users.index.add_new')

        assert_current_path(admin.create_users_path)
        assert(page.has_content?(t('workarea.admin.create_users.index.title')))
        choose t('workarea.admin.create_users.index.create_an_administrator')
        click_button "#{t('workarea.admin.create_users.index.continue')} →"

        assert_current_path(/#{admin.new_create_user_path}/)
        assert(page.has_content?(t('workarea.admin.create_users.admin.title')))
        fill_in 'user[email]', with: 'bcrouse@workarea.com'
        fill_in 'user[password]', with: 'W3bl1nc!'
        click_button t('workarea.admin.create_users.admin.create_admin')

        assert(page.has_content?('Success'))
        assert(page.has_content?('bcrouse@workarea.com'))
      end

      def test_editing_a_user
        visit admin.user_path(@user)
        click_link t('workarea.admin.cards.attributes.title')

        fill_in 'user[email]', with: 'bcrouse@workarea.com'
        fill_in 'user[password]', with: 'Passw0rd!'
        click_button 'save_user'

        assert(page.has_content?('Success'))
        assert(page.has_content?('bcrouse@workarea.com'))

        click_link t('workarea.admin.users.cards.permissions.title')
        check 'user_admin'
        click_button 'save_permissions'

        assert(page.has_content?('Success'))

        @user.update!(admin: true, super_admin: true)
        visit admin.permissions_user_path(@user)

        assert(find_field('user[admin]', disabled: true).present?)
        assert(find_field('user[permissions_manager]', disabled: true).present?)
        assert_text(t('workarea.admin.users.permissions.cannot_be_changed'))
      end

      def test_adding_an_avatar
        visit admin.edit_user_path(@user)

        attach_file 'user[avatar]', user_avatar_file_path
        click_button 'save_user'

        assert(page.has_content?('Success'))

        # For some reason, we have to look the user back up to get the avatar
        # to show up in the test, #reload is not good enough.
        @user = User.find(@user.id)
        url = @user.avatar_image_url

        visit admin.edit_user_path(@user)
        assert_includes(page.html, url)

        visit admin.edit_user_path(@user)
        check 'remove_avatar'
        click_button 'save_user'

        assert(page.has_content?('Success'))

        visit admin.edit_user_path(@user)
        refute_includes(page.html, url)
      end

      def test_user_insights
        11.times { Metrics::User.save_order(email: @user.email, revenue: 5.to_m) }

        visit admin.user_path(@user)
        assert(page.has_content?('11'))
        assert(page.has_content?('55'))
        click_link t('workarea.admin.users.cards.insights.title')

        assert(page.has_content?('11'))
        assert(page.has_content?('55'))
      end

      def test_user_locked
        @user.update(
          failed_login_count: Workarea.config.allowed_login_attempts + 1,
          last_login_attempt_at: Time.current
        )

        visit admin.user_path(@user)
        assert(page.has_content?(t('workarea.admin.users.show.locked')))

        click_link t('workarea.admin.users.show.unlock')

        assert(page.has_content?('Success'))
        assert(page.has_no_content?(t('workarea.admin.users.show.locked')))
      end

      def test_user_cart
        visit admin.user_path(@user)

        assert(page.has_content?(t('workarea.admin.users.cards.cart.empty')))

        click_link t('workarea.admin.users.cards.cart.title')
        assert(page.has_content?(t('workarea.admin.users.cart.no_order')))

        product = create_product(
          id: 'PROD1',
          name: 'Test Product',
          variants: [{ sku: 'SKU1', regular: 5.to_m }]
        )
        order = create_order(user_id: @user.id)
        order.add_item(product_id: 'PROD1', sku: 'SKU1', quantity: 2)
        Pricing.perform(order)

        visit admin.user_path(@user)

        assert(page.has_content?(order.id))
        click_link t('workarea.admin.users.cards.cart.title')

        assert(page.has_content?(product.name))
        assert(page.has_content?('SKU1'))
        assert(page.has_content?('10.00'))
      end
    end
  end
end
