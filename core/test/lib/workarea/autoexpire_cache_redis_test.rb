require 'test_helper'
require 'redis/store'

module Workarea
  class AutoexpireCacheRedisTest < TestCase
    setup :setup_redis
    teardown :clear_redis

    def test_get
      assert_equal('bar', @store[@key])
    end

    def test_set
      assert(@store[@key] = 'foo')
    end

    def test_keys
      refute_empty @store.keys
    end

    def test_del
      assert @store.del(@key)
    end

    private

    def setup_redis
      @key = 'http://example.com'
      Workarea.redis.set(@key, 'bar')
      @store = AutoexpireCacheRedis.new(Workarea.redis)
    end

    def clear_redis
      Workarea.redis.del(@key)
    end
  end
end
