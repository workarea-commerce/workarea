module Workarea
  # Execute sidekiq jobs with query caches enabled. Each job can specify one or
  # both query_caches to use via `query_cache`, `mongoid_query_cache`, or
  # `elasticsearch_query_cache` options.
  #
  # @return [ Object ] The result of the call.
  #
  class QueryCacheMiddleware
    def initialize(options = {})
      @options = options
    end

    def call(worker, msg, queue)
      cache_options = CacheOptions.new(worker.class.sidekiq_options)
      return yield if cache_options.none?

      if cache_options.all?
        Mongoid::QueryCache.cache do
          Elasticsearch::QueryCache.cache do
            yield
          end
        end
      elsif cache_options.mongoid?
        Mongoid::QueryCache.cache { yield }
      elsif cache_options.elasticsearch?
        Elasticsearch::QueryCache.cache { yield }
      end
    ensure
      Mongoid::QueryCache.clear_cache
      Elasticsearch::QueryCache.clear_cache
    end

    class CacheOptions
      def initialize(options)
        @options = options
      end

      def none?
        !mongoid? && !elasticsearch?
      end

      def all?
        mongoid? && elasticsearch?
      end

      def mongoid?
        !!(@options['mongoid_query_cache'] || @options['query_cache'])
      end

      def elasticsearch?
        !!(@options['elasticsearch_query_cache'] || @options['query_cache'])
      end
    end
  end
end
