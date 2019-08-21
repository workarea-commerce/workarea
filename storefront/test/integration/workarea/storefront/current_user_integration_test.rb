require 'test_helper'

module Workarea
  module Storefront
    class CurrentUserIntegrationTest < Workarea::IntegrationTest
      def test_returns_admin_true_when_impersonating
        admin_user = create_user(password: 'W3bl1nc!', super_admin: true)
        non_admin = create_user

        post storefront.login_path,
          params: { email: admin_user.email, password: 'W3bl1nc!' }

        get storefront.current_user_path(format: 'json')
        results = JSON.parse(response.body)
        assert(results['admin'])

        post admin.impersonations_path, params: { user_id: non_admin.id }

        get storefront.current_user_path(format: 'json')
        results = JSON.parse(response.body)

        assert(results['admin'], 'user is not admin')
        assert_equal(ApplicationController.request_forgery_protection_token.to_s, results['csrf_param'])
        assert(results['csrf_token'].present?, 'csrf token not found')
      end
    end
  end
end
