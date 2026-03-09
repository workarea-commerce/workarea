# frozen_string_literal: true

require 'test_helper'
require 'bigdecimal'

module Workarea
  class SessionCookieSerializerRoundTripTest < ActionDispatch::IntegrationTest
    test 'session cookie store round-trips common value types' do
      retrieved = nil

      payload = {
        'string' => 'hello',
        'integer' => 123,
        'big_decimal' => BigDecimal('12.34'),
        'time' => Time.utc(2026, 3, 9, 12, 34, 56),
        'time_with_zone' => Time.use_zone('Eastern Time (US & Canada)') { Time.zone.local(2026, 3, 9, 7, 34, 56) },
        'array' => [1, 'two', { 'three' => 3 }],
        'hash' => {
          'nested_string' => 'value',
          'nested_array' => %w[a b],
          'nested_hash' => { 'c' => 'd' }
        }
      }

      app = lambda do |env|
        request = ActionDispatch::Request.new(env)

        case request.path
        when '/write'
          request.session['payload'] = payload
        when '/read'
          retrieved = request.session['payload']
        else
          raise "Unexpected path: #{request.path.inspect}"
        end

        [200, { 'Content-Type' => 'text/plain' }, ['ok']]
      end

      # Mirror the relevant part of the Rails middleware stack:
      # cookies must run before the cookie-based session store.
      stack = ActionDispatch::Cookies.new(
        ActionDispatch::Session::CookieStore.new(
          app,
          key: '_workarea_session_serializer_test',
          same_site: :lax,
          secure: false
        )
      )

      request = Rack::MockRequest.new(stack)

      # Rails 6.1 requires several action_dispatch.* env vars to be present in
      # the Rack env — normally injected by the full middleware stack
      # (ActionDispatch::Executor / railtie initializers).  Rack::MockRequest
      # bypasses all of that, so we populate them from the running Rails app.
      # Rails 7+ derives signing/encryption keys from the middleware options and
      # does not require these in the env, so providing them is a harmless no-op.
      rack_env = rails_cookie_env

      write_response = request.get('/write', rack_env)
      cookie_header = write_response['Set-Cookie']
      assert cookie_header.present?, 'Expected Set-Cookie header to be set'

      request.get('/read', rack_env.merge('HTTP_COOKIE' => cookie_header))

      # Our dummy app config uses :json cookies_serializer, which will coerce
      # non-JSON-native types (BigDecimal, Time, ActiveSupport::TimeWithZone)
      # into strings.
      expected = payload.deep_dup
      expected['big_decimal'] = payload['big_decimal'].to_s
      expected['time'] = payload['time'].as_json
      expected['time_with_zone'] = payload['time_with_zone'].as_json

      assert_equal expected, retrieved
    end

    private

    # Builds the minimal set of Rack env vars that ActionDispatch::Cookies and
    # ActionDispatch::Session::CookieStore need when used outside a full Rails
    # middleware stack (e.g. with Rack::MockRequest).
    #
    # Rails 6.1 reads key_generator, cookie salts, and the serializer from the
    # Rack env.  Rails 7+ infers them from the middleware/app options, so these
    # entries are harmless no-ops on later versions.
    def rails_cookie_env
      env = {}
      ad = Rails.application.config.action_dispatch

      # Signing/encryption key generator (Rails 6.1 required, 7+ optional).
      if Rails.application.respond_to?(:key_generator)
        env['action_dispatch.key_generator'] = Rails.application.key_generator
      end

      # Cookie salts and feature flags — read from the running app's config so
      # the mock requests use the same values as the real cookie jar.
      {
        'action_dispatch.signed_cookie_salt'                  => :signed_cookie_salt,
        'action_dispatch.encrypted_cookie_salt'               => :encrypted_cookie_salt,
        'action_dispatch.encrypted_signed_cookie_salt'        => :encrypted_signed_cookie_salt,
        'action_dispatch.authenticated_encrypted_cookie_salt' => :authenticated_encrypted_cookie_salt,
        'action_dispatch.use_authenticated_cookie_encryption' => :use_authenticated_cookie_encryption,
        'action_dispatch.cookies_serializer'                  => :cookies_serializer,
      }.each do |env_key, config_attr|
        val = ad.public_send(config_attr)
        env[env_key] = val unless val.nil?
      end

      env
    end
  end
end
