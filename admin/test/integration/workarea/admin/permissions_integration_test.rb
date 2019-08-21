require 'test_helper'

module Workarea
  module Admin
    class PermissionsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      setup :set_user

      def set_user
        @user = create_user(admin: true)
        set_current_user(@user)
      end

      def test_redirects_if_you_do_not_have_permissions
        get admin.catalog_products_path
        assert(response.redirect?)
      end

      def test_allows_if_you_do_have_permissions
        @user.update_attributes!(catalog_access: true)
        get admin.catalog_products_path
        assert(response.ok?)
      end
    end
  end
end
