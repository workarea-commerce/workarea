module Workarea
  module Configuration
    module CacheStore
      extend self

      def load
        if Rails.env.test?
          Rails.application.config.cache_store = :null_store
        elsif !Rails.env.development?
          Rails.application.config.cache_store = :redis_store, Workarea::Configuration::Redis.cache.to_url

          require 'redis-rack-cache'
          Rails.application.config.action_dispatch.rack_cache = {
            metastore: Workarea::Configuration::Redis.cache.to_url,
            entitystore: Workarea::Configuration::Redis.cache.to_url
          }
        end
      end
    end
  end
end
