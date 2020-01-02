require 'test_helper'

module Workarea
  module Configuration
    class RedisTest < TestCase
      def test_find_config
        ENV['WORKAREA_FOO_REDIS_PORT'] = '1234'
        Workarea.config.foo_redis = { scheme: 'rediss' }

        result = Redis.find_config(:foo_redis)
        assert_equal('rediss', result[:scheme])
        assert_equal('1234', result[:port])

      ensure
        ENV.delete('WORKAREA_FOO_REDIS_PORT')
      end

      def test_defaults
        instance = Redis.new(host: 'foo')
        assert_equal('redis', instance.scheme)
        assert_equal('foo', instance.host)
        assert_equal(6379, instance.port)
        assert_equal(0, instance.db)
        refute(instance.ssl?)
        assert_match(URI::regexp, instance.to_url)

        instance = Redis.new(scheme: 'rediss')
        assert_equal('rediss', instance.scheme)
        assert_equal('localhost', instance.host)
        assert_equal(6379, instance.port)
        assert_equal(0, instance.db)
        assert(instance.ssl?)
        assert_match(URI::regexp, instance.to_url)
      end

      def test_to_h
        result = Redis.new(scheme: 'rediss', port: 1234).to_h
        assert_equal('rediss', result[:scheme])
        assert_equal('localhost', result[:host])
        assert_equal(1234, result[:port])
        assert_equal(0, result[:db])
        assert_nil(result[:password])
        assert(result[:ssl])
      end
    end
  end
end
