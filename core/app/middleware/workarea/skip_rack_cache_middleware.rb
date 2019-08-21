module Workarea
  # TODO here for legacy support, remove in v4
  class SkipRackCacheMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)

      if request.path !~ /(jpe?g|png|ico|gif|css|js)$/ &&
          request.cookies['cache'] == 'false'
        env["rack-cache.force-pass"] = true
      end

      @app.call(env)
    end
  end
end
