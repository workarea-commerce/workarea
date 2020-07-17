require 'test_helper'

module Workarea
  class RackAttackIntegrationTest < Workarea::IntegrationTest
    class AddEnvMiddleware
      def initialize(app)
        @app = app
      end

      def call(env)
        env.merge!(Rails.application.env_config)
        @app.call(env)
      end
    end

    def test_safelist_kubernetes_health_checks
      get '/', env: { 'REMOTE_ADDR' => Rack::Attack::KUBERNETES_IP_ADDRESS }

      assert_response(:success)
      assert_equal('ignore/k8s', request.env['rack.attack.matched'])
      assert_equal(:safelist, request.env['rack.attack.match_type'])
    end

    def test_safelist_configuration_field
      ip = '192.168.1.1'

      Workarea::Configuration::Admin.instance.update!(safe_ip_addresses: [ip])

      get '/', env: { 'REMOTE_ADDR' => ip }

      assert_response(:success)
      assert_equal('ignore/config', request.env['rack.attack.matched'])
      assert_equal(:safelist, request.env['rack.attack.match_type'])

      Workarea::Configuration::Admin.instance.update!(safe_ip_addresses: ['foo'])

      get '/', env: { 'REMOTE_ADDR' => ip }

      assert_response(:success)
      assert_nil(request.env['rack.attack.matched'])
    end

    def test_blocklist_configuration_field
      ip = '192.168.1.1'

      get '/', env: { 'REMOTE_ADDR' => ip }

      assert_response(:success)

      Workarea::Configuration::Admin.instance.update!(blocked_ip_addresses: [ip])

      get '/', env: { 'REMOTE_ADDR' => ip }

      assert_response(:forbidden)
      assert_equal('block/config', request.env['rack.attack.matched'])
      assert_equal(:blocklist, request.env['rack.attack.match_type'])

      Workarea::Configuration::Admin.instance.update!(blocked_ip_addresses: ['foo'])

      get '/', env: { 'REMOTE_ADDR' => ip }

      assert_response(:success)
    end

    def test_throttle_all_requests
      ip = '192.168.1.1'

      get '/', env: { 'REMOTE_ADDR' => ip }

      assert_response(:success)

      Rack::Attack.cache.stubs(:count).returns(0)
      Rack::Attack.cache.stubs(:count).with("req/ip:#{ip}", 300).returns(301)

      get '/', env: { 'REMOTE_ADDR' => ip }

      assert_response(429)
      assert_equal('req/ip', request.env['rack.attack.matched'])
      assert_equal(:throttle, request.env['rack.attack.match_type'])
    end

    def test_throttle_login_attempts_by_ip
      ip = '192.168.1.1'

      post '/login', env: { 'REMOTE_ADDR' => ip }

      assert_response(:success)

      Rack::Attack.cache.stubs(:count).returns(0)
      Rack::Attack.cache.stubs(:count).with("logins/ip:#{ip}", 20).returns(6)

      post '/login', env: { 'REMOTE_ADDR' => ip }

      assert_response(429)
      assert_equal('logins/ip', request.env['rack.attack.matched'])
      assert_equal(:throttle, request.env['rack.attack.match_type'])
    end

    def test_throttle_login_attempts_by_email
      email = 'test@example.com'

      post '/login', params: { email: email }

      assert_response(:success)

      Rack::Attack.cache.stubs(:count).returns(0)
      Rack::Attack.cache.stubs(:count).with("logins/email:#{email}", 20).returns(6)

      post '/login', params: { email: email }

      assert_response(429)
      assert_equal('logins/email', request.env['rack.attack.matched'])
      assert_equal(:throttle, request.env['rack.attack.match_type'])
    end

    def test_throttle_contact_requests_by_ip
      ip = '192.168.1.1'

      post '/contact', env: { 'REMOTE_ADDR' => ip }

      assert_response(:success)

      Rack::Attack.cache.stubs(:count).returns(0)
      Rack::Attack.cache.stubs(:count).with("contact/ip:#{ip}", 1.minute.to_i).returns(4)
      post '/contact', env: { 'REMOTE_ADDR' => ip }

      assert_response(429)
      assert_equal('contact/ip', request.env['rack.attack.matched'])
      assert_equal(:throttle, request.env['rack.attack.match_type'])
    end

    def test_throttle_email_signups_by_ip
      ip = '192.168.1.1'

      post '/email_signup', env: { 'REMOTE_ADDR' => ip }

      assert_response(:success)

      Rack::Attack.cache.stubs(:count).returns(0)
      Rack::Attack.cache.stubs(:count).with("email_signup/ip:#{ip}", 20.minutes.to_i).returns(11)
      post '/email_signup', env: { 'REMOTE_ADDR' => ip }

      assert_response(429)
      assert_equal('email_signup/ip', request.env['rack.attack.matched'])
      assert_equal(:throttle, request.env['rack.attack.match_type'])
    end

    def test_throttle_email_signups_by_email
      email = 'test@example.com'

      post '/email_signup', params: { email: email }

      assert_response(:success)

      Rack::Attack.cache.stubs(:count).returns(0)
      Rack::Attack.cache.stubs(:count).with("email_signup/email:#{email}", 20.minutes.to_i).returns(11)
      post '/email_signup', params: { email: email }

      assert_response(429)
      assert_equal('email_signup/email', request.env['rack.attack.matched'])
      assert_equal(:throttle, request.env['rack.attack.match_type'])
    end

    def test_throttle_password_resets_by_email
      email = 'test@example.com'

      post '/forgot_password', params: { email: email }

      assert_response(:success)

      Rack::Attack.cache.stubs(:count).returns(0)
      Rack::Attack.cache.stubs(:count).with("password_reset/email:#{email}", 20.minutes.to_i).returns(11)
      post '/forgot_password', params: { email: email }

      assert_response(429)
      assert_equal('password_reset/email', request.env['rack.attack.matched'])
      assert_equal(:throttle, request.env['rack.attack.match_type'])
    end

    def test_throttle_password_resets_by_ip
      ip = '192.168.1.1'

      post '/forgot_password', env: { 'REMOTE_ADDR' => ip }

      assert_response(:success)

      Rack::Attack.cache.stubs(:count).returns(0)
      Rack::Attack.cache.stubs(:count).with("password_reset/ip:#{ip}", 20.minutes.to_i).returns(11)
      post '/forgot_password', env: { 'REMOTE_ADDR' => ip }

      assert_response(429)
      assert_equal('password_reset/ip', request.env['rack.attack.matched'])
      assert_equal(:throttle, request.env['rack.attack.match_type'])
    end

    private

    def app
      @app ||= begin
        Rack::Builder.new do
          use AddEnvMiddleware
          use Rack::Attack
          use ActionDispatch::Cookies
          run -> (*) { [ 200, {}, [] ] }
        end
      end
    end
  end
end
