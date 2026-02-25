module Workarea
  module Elasticsearch
    module QueryCache
      thread_mattr_accessor :query_cache, :query_cache_enabled

      class << self
        # Get the cached queries.
        #
        # @example Get the cached queries from the current thread.
        #   QueryCache.cache_table
        #
        # @return [ Hash ] The hash of cached queries.
        def cache_table
          self.query_cache ||= {}
        end

        # Clear the query cache.
        #
        # @example Clear the cache.
        #   QueryCache.clear_cache
        #
        # @return [ nil ] Always nil.
        def clear_cache
          self.query_cache = nil
        end

        # Set whether the cache is enabled.
        #
        # @example Set if the cache is enabled.
        #   QueryCache.enabled = true
        #
        # @param [ true, false ] value The enabled value.
        def enabled=(value)
          self.query_cache_enabled = value
        end

        # Is the query cache enabled on the current thread?
        #
        # @example Is the query cache enabled?
        #   QueryCache.enabled?
        #
        # @return [ true, false ] If the cache is enabled.
        def enabled?
          !!self.query_cache_enabled
        end

        # Execute the block while using the query cache.
        #
        # @example Execute with the cache.
        #   QueryCache.cache { collection.find }
        #
        # @return [ Object ] The result of the block.
        def cache
          enabled = QueryCache.enabled?
          QueryCache.enabled = true
          yield
        ensure
          QueryCache.enabled = enabled
        end

        # Execute the block with the query cache disabled.
        #
        # @example Execute without the cache.
        #   QueryCache.uncached { collection.find }
        #
        # @return [ Object ] The result of the block.
        def uncached
          enabled = QueryCache.enabled?
          QueryCache.enabled = false
          yield
        ensure
          QueryCache.enabled = enabled
        end
      end

      # The middleware to be added to a rack application in order to activate the
      # query cache.
      class Middleware

        # Instantiate the middleware.
        #
        # @example Create the new middleware.
        #   Middleware.new(app)
        #
        # @param [ Object ] app The rack applciation stack.
        def initialize(app)
          @app = app
        end

        # Execute the request, wrapping in a query cache.
        #
        # @example Execute the request.
        #   middleware.call(env)
        #
        # @param [ Object ] env The environment.
        #
        # @return [ Object ] The result of the call.
        def call(env)
          QueryCache.cache { @app.call(env) }
        ensure
          QueryCache.clear_cache
        end
      end

      module Client
        # bypass unless cache enabled
        #
        # if post, clear cache and super
        # else fetch or perform and store
        def perform_request(method, path, params = {}, body = nil)
          return super unless QueryCache.enabled?

          # elasticsearch-ruby may send search requests with a request body as
          # POST (or convert GET-with-body into POST). Those are still read-only
          # operations and should be cacheable.
          original_method = method.to_s.upcase
          method = original_method
          method = @send_get_body_as.to_s.upcase if method == 'GET' && body

          cacheable_post = (
            method == 'POST' &&
            path.end_with?('/_search')
          )

          if method == 'GET' || cacheable_post
            cache_key = [original_method, method, path.to_s, params, body]

            unless (response = QueryCache.cache_table[cache_key])
              response = transport.perform_request(method, path, params, body)
              QueryCache.cache_table[cache_key] = response
            end

            response
          else
            QueryCache.clear_cache
            transport.perform_request(method, path, params, body)
          end
        end
      end
    end
  end
end

Elasticsearch::Transport::Client.__send__(:prepend, Workarea::Elasticsearch::QueryCache::Client)
