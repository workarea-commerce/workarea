require 'test_helper'
require 'bigdecimal'
require 'securerandom'

module Workarea
  class CacheRoundTripSmokeTest < Workarea::TestCase
    def redis_cache
      @redis_cache ||= ActiveSupport::Cache.lookup_store(
        :redis_cache_store,
        url: Workarea::Configuration::Redis.cache.to_url,
        namespace: 'workarea-test',
        expires_in: 1.minute
      )
    end

    def test_big_decimal_round_trips_through_cache
      key = "cache-round-trip-big-decimal-#{SecureRandom.hex(8)}"
      value = BigDecimal('123.45')

      redis_cache.write(key, value)
      cached = redis_cache.read(key)

      assert_kind_of(BigDecimal, cached)
      assert_equal(value, cached)
      assert_equal('123.45', cached.to_s('F'))
    ensure
      redis_cache.delete(key)
    end

    def test_time_with_zone_round_trips_through_cache
      key = "cache-round-trip-time-with-zone-#{SecureRandom.hex(8)}"

      Time.use_zone('Eastern Time (US & Canada)') do
        value = Time.zone.parse('2026-03-08 01:23:45')

        redis_cache.write(key, value)
        cached = redis_cache.read(key)

        assert_kind_of(ActiveSupport::TimeWithZone, cached)
        assert_equal(value, cached)
        assert_equal(value.time_zone.name, cached.time_zone.name)
      end
    ensure
      redis_cache.delete(key)
    end
  end
end
