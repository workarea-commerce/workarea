module Workarea
  module Configuration
    module CacheStore
      extend self

      def load
        if Rails.env.test?
          Rails.application.config.cache_store = :null_store
        elsif !Rails.env.development?
          Rails.application.config.cache_store = :redis_cache_store, {
            url: Workarea::Configuration::Redis.cache.to_url
          }

          # rack-cache is not compatible with Rails 7.1+; use ActionDispatch HTTP
          # caching instead (stale?, fresh_when, expires_in on controllers).
          if Rails::VERSION::MAJOR < 7 || (Rails::VERSION::MAJOR == 7 && Rails::VERSION::MINOR < 1)
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
end
