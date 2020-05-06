require 'test_helper'

module Workarea
  module Storefront
    class CurrentCheckoutIntegrationTest < Workarea::IntegrationTest
      class CurrentCheckoutController < Storefront::ApplicationController
        before_action :require_login, only: :logged_in

        def test
          current_order.save if params[:save]
          head :ok
        end

        def test_login
          login(User.find(params[:user_id]))
          self.current_order = Order.create!(id: params[:order_id]) if params[:order_id].present?
          head :ok
        end

        def logged_in
          head :ok
        end

        def test_logout
          logout
          head :ok
        end
      end

      setup do
        Rails.application.routes.prepend do
          get 'current_checkout_test', to: "#{CurrentCheckoutController.controller_path}#test"
          get 'current_checkout_test_login', to: "#{CurrentCheckoutController.controller_path}#test_login"
          get 'current_checkout_test_logout', to: "#{CurrentCheckoutController.controller_path}#test_logout"
          get 'current_checkout_test_login_required', to: "#{CurrentCheckoutController.controller_path}#logged_in"
        end

        Rails.application.reload_routes!

        @user = create_user
      end

      def test_current_order
        get '/current_checkout_test'
        assert(cookies[:order_id].blank?)

        get '/current_checkout_test', params: { save: true }
        assert(cookies[:order_id].present?)
      end

      def test_clearing_current_order
        get '/current_checkout_test_login', params: { user_id: @user.id, order_id: 'foo' }
        assert(cookies[:order_id].present?)

        get '/current_checkout_test_logout'
        assert(cookies[:order_id].blank?)
      end

      def test_require_login_does_not_clear_current_order
        get '/current_checkout_test', params: { save: true }
        assert(cookies[:order_id].present?)

        assert_no_changes 'cookies[:order_id]' do
          get '/current_checkout_test_login_required'
        end
      end

      def test_ip_address_changing_clears_current_order
        get '/current_checkout_test_login', params: { user_id: @user.id, order_id: 'foo' }

        get '/current_checkout_test_login_required'
        assert(cookies[:order_id].present?)

        @user.update!(ip_address: '192.168.0.1')

        get '/current_checkout_test_login_required'
        assert(cookies[:order_id].blank?)
      end
    end
  end
end
