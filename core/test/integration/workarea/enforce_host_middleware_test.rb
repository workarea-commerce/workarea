# frozen_string_literal: true

require 'test_helper'

module Workarea
  # Integration tests for Workarea::EnforceHostMiddleware.
  #
  # Verifies that the middleware:
  #   1. Can be loaded as a constant (smoke test for the require_relative fix
  #      introduced in PR #1066 to resolve a Rails 7.0 NameError).
  #   2. Passes requests through unchanged when enforce_host is disabled.
  #   3. Passes requests through unchanged when the host matches the configured host.
  #   4. Redirects (301) to the canonical host when the request host differs.
  #   5. Skips enforcement when the skip_enforce_host proc returns true.
  #
  # The Rack app is constructed inline so these tests remain fast and isolated
  # from the full middleware stack (see RackAttackIntegrationTest for precedent).
  class EnforceHostMiddlewareTest < ActionDispatch::IntegrationTest
    # Minimal Rack app returned after the middleware passes a request through.
    PASS_APP = ->(_env) { [200, { 'Content-Type' => 'text/plain' }, ['OK']] }

    # -----------------------------------------------------------------------
    # Load / constant smoke test
    # -----------------------------------------------------------------------

    test 'EnforceHostMiddleware constant is defined' do
      assert defined?(Workarea::EnforceHostMiddleware),
        'Workarea::EnforceHostMiddleware should be defined — likely a require_relative regression'
    end

    test 'EnforceHostMiddleware is present in the middleware stack' do
      stack = Rails.application.middleware.map(&:klass)
      assert_includes stack, Workarea::EnforceHostMiddleware,
        'EnforceHostMiddleware must appear in Rails.application.middleware'
    end

    # -----------------------------------------------------------------------
    # Behavioural tests (isolated Rack stack)
    # -----------------------------------------------------------------------

    test 'passes through when enforce_host is disabled' do
      with_config(enforce_host: false, host: 'www.example.com') do
        env = Rack::MockRequest.env_for('http://other-host.example.com/')
        status, _headers, _body = middleware_app.call(env)
        assert_equal 200, status
      end
    end

    test 'passes through when request host matches configured host' do
      with_config(enforce_host: true, host: 'www.example.com') do
        env = Rack::MockRequest.env_for('http://www.example.com/some/path')
        status, _headers, _body = middleware_app.call(env)
        assert_equal 200, status
      end
    end

    test 'redirects with 301 when host does not match' do
      with_config(enforce_host: true, host: 'www.example.com') do
        env = Rack::MockRequest.env_for('http://wrong-host.example.com/some/path?q=1')
        status, headers, _body = middleware_app.call(env)

        assert_equal 301, status
        assert_equal 'http://www.example.com/some/path?q=1', headers['Location']
      end
    end

    test 'redirect preserves the original scheme' do
      with_config(enforce_host: true, host: 'www.example.com') do
        env = Rack::MockRequest.env_for('https://wrong.example.com/secure')
        # Rack::MockRequest doesn't automatically set HTTPS; set it manually.
        env['HTTPS'] = 'on'
        env['rack.url_scheme'] = 'https'
        _status, headers, _body = middleware_app.call(env)

        assert headers['Location'].start_with?('https://'),
          "Expected redirect to preserve https scheme, got: #{headers['Location']}"
      end
    end

    test 'passes through when skip_enforce_host proc returns true' do
      with_config(
        enforce_host: true,
        host: 'www.example.com',
        skip_enforce_host: ->(_request) { true }
      ) do
        env = Rack::MockRequest.env_for('http://wrong-host.example.com/')
        status, _headers, _body = middleware_app.call(env)
        assert_equal 200, status
      end
    end

    test 'enforces host when skip_enforce_host proc returns false' do
      with_config(
        enforce_host: true,
        host: 'www.example.com',
        skip_enforce_host: ->(_request) { false }
      ) do
        env = Rack::MockRequest.env_for('http://wrong-host.example.com/')
        status, _headers, _body = middleware_app.call(env)
        assert_equal 301, status
      end
    end

    private

    def middleware_app
      Workarea::EnforceHostMiddleware.new(PASS_APP)
    end

    # Temporarily overrides Workarea.config values for the duration of the
    # block, then restores originals.  Only touches the keys passed in.
    def with_config(overrides)
      originals = overrides.keys.each_with_object({}) do |key, memo|
        memo[key] = Workarea.config.send(key)
      end

      overrides.each { |key, val| Workarea.config.send(:"#{key}=", val) }

      yield
    ensure
      originals.each { |key, val| Workarea.config.send(:"#{key}=", val) }
    end
  end
end
