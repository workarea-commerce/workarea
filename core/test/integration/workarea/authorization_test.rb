require 'test_helper'

module Workarea
  class AuthorizationTest < IntegrationTest
    class AuthorizationController < Workarea::ApplicationController
      include Authentication
      include Authorization

      before_action :check_authorization

      def test
        head :ok
      end

      def root_path
        '/'
      end
    end

    setup do
      Rails.application.routes.prepend do
        get 'authorization_test', to: 'workarea/authorization_test/authorization#test'
      end

      Rails.application.reload_routes!

      @user = create_user
      set_current_user(@user)
    end

    teardown do
      AuthorizationController.reset_permissions!
    end

    def assert_authorized
      get '/authorization_test'
      refute(response.redirect?)
      assert(response.ok?)
    end

    def refute_authorized
      get '/authorization_test'
      assert(response.redirect?)
      assert(flash[:error].present?)
    end

    def test_allowing_super_admins
      AuthorizationController.required_permissions(:store)
      @user.update_attributes!(super_admin: true)
      assert_authorized
    end

    def test_blank_requirements
      @user.update_attributes!(admin: true)
      assert_authorized
    end

    def test_invalid_permissions
      AuthorizationController.required_permissions(:store)
      @user.update_attributes!(admin: true)
      refute_authorized
    end

    def test_valid_permissions
      AuthorizationController.required_permissions(:store)
      @user.update_attributes!(admin: true, store_access: true)
      assert_authorized

      AuthorizationController.reset_permissions!
      AuthorizationController.required_permissions(:orders_manager)
      @user.update_attributes!(admin: true, orders_manager: true)
      assert_authorized
    end

    def test_non_admins
      AuthorizationController.required_permissions(:store)
      refute_authorized
    end

    def test_multiple_permissions_requirements
      AuthorizationController.required_permissions(:store, :catalog)

      @user.update_attributes!(admin: true)
      refute_authorized

      @user.update_attributes!(store_access: true)
      refute_authorized

      @user.update_attributes!(catalog_access: true)
      assert_authorized
    end
  end
end
