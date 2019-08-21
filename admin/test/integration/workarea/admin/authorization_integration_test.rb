require 'test_helper'

module Workarea
  module Admin
    class AuthorizationIntegrationTest < Workarea::IntegrationTest
      setup :set_user

      def set_user
        @user = create_user(admin: true, password: 'W3bl1nc!')
      end

      def test_allows_the_request_when_admin_user
        # login
        post storefront.login_path,
          params: { email: @user.email, password: 'W3bl1nc!' }

        get '/admin'
        assert(response.ok?)
      end

      def test_does_not_allow_the_request_when_non_admin_user
        # login
        @user.update_attributes!(admin: false)
        post storefront.login_path,
          params: { email: @user.email, password: 'W3bl1nc!' }

        get '/admin'
        assert(response.redirect?)
      end
    end
  end
end
