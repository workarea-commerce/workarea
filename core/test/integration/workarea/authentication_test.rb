require 'test_helper'

module Workarea
  class AuthenticationTest < IntegrationTest
    class AuthenticationController < Workarea::ApplicationController
      include HttpCaching
      include Authentication
      include Impersonation
      include Storefront::CurrentCheckout

      before_action :cache_page, only: :cached
      before_action :require_login, only: :logged_in
      before_action :require_logout, only: :logged_out
      before_action :require_password_changes

      def test_login
        login(User.find(params[:user_id]))
        redirect_back_or '/account'
      end

      def test_logout
        logout
        head :ok
      end

      def logged_in
        head :ok
      end

      def foo
        head :ok
      end

      def logged_out
        head :ok
      end

      def cached
        render plain: 'cached'
      end
    end

    setup do
      Rails.application.routes.prepend do
        get 'test_login', to: 'workarea/authentication_test/authentication#test_login'
        get 'test_logout', to: 'workarea/authentication_test/authentication#test_logout'
        get 'login_required', to: 'workarea/authentication_test/authentication#logged_in'
        get 'logout_required', to: 'workarea/authentication_test/authentication#logged_out'
        get 'foo', to: 'workarea/authentication_test/authentication#foo'
        get 'cached', to: 'workarea/authentication_test/authentication#cached'
      end
      Rails.application.reload_routes!

      @user = create_user
    end

    def test_login_and_logout
      get '/login_required'
      refute(response.ok?)
      assert(response.redirect?)
      assert(flash[:info].present?)

      get '/test_login', params: { user_id: @user.id }

      get '/login_required'
      assert(response.ok?)
      refute(response.redirect?)

      get '/test_logout'

      get '/login_required'
      refute(response.ok?)
      assert(response.redirect?)
      assert(flash[:info].present?)
    end

    def test_login_redirection
      get '/login_required', params: { foo: 'bar' }
      get '/test_login', params: { user_id: @user.id }
      assert(response.redirect?)
      assert(response.location.end_with?('/login_required?foo=bar'))

      get '/test_logout'

      get '/login_required', params: { return_to: '/foo/bar' }
      get '/test_login', params: { user_id: @user.id }
      assert(response.redirect?)
      assert(response.location.end_with?('/foo/bar'))

      get '/test_logout'

      get '/test_login', params: { user_id: @user.id }
      assert(response.redirect?)
      assert(response.location.end_with?('/account'))

      get '/test_logout'

      get '/login_required', params: { return_to: 'http://google.com/blah' }
      get '/test_login', params: { user_id: @user.id }
      assert(response.redirect?)
      assert_equal('http://www.example.com/blah', response.location)

      get '/test_logout'
      path = '/?like_text=' + 9000.times.map { 'ROFL' }.join
      get '/login_required', params: { return_to: path }
      assert_response(:redirect)
    end

    def test_actions_that_require_logout
      get '/test_login', params: { user_id: @user.id }
      get '/logout_required'
      assert(flash[:info].present?)
      assert(response.redirect?)

      get '/test_logout'
      get '/logout_required'
      assert(response.ok?)
      refute(response.redirect?)
    end

    def test_ip_address_changing
      get '/test_login', params: { user_id: @user.id }

      get '/login_required'
      assert(response.ok?)
      refute(response.redirect?)

      @user.update_attributes!(ip_address: '192.168.0.1')

      get '/login_required'
      assert(flash[:info].present?)
      assert(response.redirect?)
    end

    def test_saving_user_request_details
      get '/test_login',
        params: { user_id: @user.id },
        headers: { 'HTTP_USER_AGENT' => 'Foo' }

      @user.reload
      assert_equal(@user.ip_address, '127.0.0.1')
      assert_equal(@user.user_agent, 'Foo')
    end

    def test_turning_off_cache_for_admins
      Workarea.config.strip_http_caching_in_tests = false

      get '/cached'
      assert_match(/public/, response.headers['Cache-Control'])

      get '/test_login', params: { user_id: @user.id }
      get '/cached'
      assert_match(/public/, response.headers['Cache-Control'])

      get '/test_logout'
      @user.update!(admin: true)
      get '/test_login', params: { user_id: @user.id }

      get '/cached'
      assert_match(/private/, response.headers['Cache-Control'])
    end

    def test_show_change_password_form_when_password_expires
      admin = create_user(admin: true)
      admin.update!(password_changed_at: (Workarea.config.password_lifetime + 1.minute).ago)

      assert(admin.force_password_change?)

      get '/test_login', params: { user_id: admin.id }

      assert_response(:redirect)

      get '/login_required', params: { user_id: admin.id }

      assert_redirected_to(storefront.change_password_path)

      get '/foo', params: { user_id: admin.id }, xhr: true

      assert_response(:unauthorized)
    end

    def test_setting_email_cookie
      get '/test_login', params: { user_id: @user.id }
      assert(cookies[:email].present?)

      get '/test_logout'
      refute(cookies[:email].present?)
    end

    def test_ensures_locale_passthrough_for_return_to
      set_locales(available: [:en, :es], default: :en, current: :en)

      get '/login_required', params: { locale: 'es', return_to: '/blah?foo=bar' }
      get '/test_login', params: { user_id: @user.id }
      assert(response.redirect?)
      assert_match('locale=es', response.location)
      assert_match('foo=bar', response.location)
    end
  end
end
