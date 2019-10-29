module Workarea
  class ApplicationMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      return @app.call(env) if request.path =~ /(jpe?g|png|ico|gif|css|js)$/

      setup_environment(env, request)
      set_segment_request_headers(env)
      status, headers, body = @app.call(env)
      set_segment_response_headers(env, headers)

      [status, headers, body]
    end

    def setup_environment(env, request)
      env['workarea.visit'] = Visit.new(env)
      env['workarea.cache_varies'] = Cache::Varies.new(env['workarea.visit']).to_s
      env['rack-cache.cache_key'] = Cache::RackCacheKey
      env['rack-cache.force-pass'] = request.cookies['cache'] == 'false'
    end

    def set_segment_request_headers(env)
      normalized_segment_ids = env['workarea.visit'].segments.map(&:id).sort.join(',')
      env['HTTP_X_WORKAREA_SEGMENTS'] = normalized_segment_ids
    end

    def set_segment_response_headers(env, headers)
      headers['X-Workarea-Segments'] = env['HTTP_X_WORKAREA_SEGMENTS']

      if headers['X-Workarea-Segmented-Content'] == 'true'
        headers['Cache-Control'] = 'private, no-cache, max-age=0'
      end
    end
  end
end
