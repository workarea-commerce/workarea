module Workarea
  class ApplicationMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      return @app.call(env) if request.path =~ /(jpe?g|png|ico|gif|css|js|svg)$/

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
      env['rack-cache.force-pass'] = env['workarea.visit'].admin?
    end

    def set_segment_request_headers(env)
      env['HTTP_X_WORKAREA_SEGMENTS'] = normalize_segment_ids(env['workarea.visit'])
    end

    def set_segment_response_headers(env, headers)
      headers['X-Workarea-Segments'] = normalize_segment_ids(env['workarea.visit'])

      if headers['X-Workarea-Segmented-Content'] == 'true'
        headers['Cache-Control'] = 'private, no-cache, max-age=0'
      end
    end

    private

    def normalize_segment_ids(visit)
      visit.applied_segments.map(&:id).sort.join(',')
    end
  end
end
