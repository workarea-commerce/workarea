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

      write_response = request.get('/write')
      cookie_header = write_response['Set-Cookie']
      assert cookie_header.present?, 'Expected Set-Cookie header to be set'

      request.get('/read', 'HTTP_COOKIE' => cookie_header)

      # Our dummy app config uses :json cookies_serializer, which will coerce
      # non-JSON-native types (BigDecimal, Time, ActiveSupport::TimeWithZone)
      # into strings.
      expected = payload.deep_dup
      expected['big_decimal'] = payload['big_decimal'].to_s
      expected['time'] = payload['time'].as_json
      expected['time_with_zone'] = payload['time_with_zone'].as_json

      assert_equal expected, retrieved
    end
  end
end
