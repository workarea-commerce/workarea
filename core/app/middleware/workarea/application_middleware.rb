module Workarea
  class ApplicationMiddleware
    ASSET_REGEX = /(jpe?g|png|ico|gif|bmp|webp|tif?f|css|js|svg|otf|ttf|woff|woff2)$/

    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      env['workarea.asset_request'] = request.path =~ ASSET_REGEX
      return @app.call(env) if env['workarea.asset_request']

      set_locale(env, request)
      setup_environment(env, request)
      set_segment_request_headers(env)
      status, headers, body = @app.call(env)
      set_segment_response_headers(env, headers)

      [status, headers, body]
    end

    def set_locale(env, request)
      I18n.locale = locale_from_request(env, request) || I18n.default_locale
    end

    def setup_environment(env, request)
      env['workarea.visit'] = Visit.new(env)
      env['workarea.cache_varies'] = Cache::Varies.new(env['workarea.visit']).to_s
      env['rack-cache.cache_key'] = Cache::RackCacheKey
      env['rack-cache.force-pass'] = env['workarea.visit'].admin? && !env['workarea.asset_request']
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

    def locale_from_request(env, request)
      return request.params['locale'] if request.params['locale'].present?

      env_with_method = env.merge(
        method: request.params[Rack::MethodOverride::METHOD_OVERRIDE_PARAM_KEY].presence ||
          request.request_method
      )
      Rails.application.routes.recognize_path(request.path, env_with_method)[:locale]

    rescue ActionController::RoutingError
      # Return nil since we can't get locale out of this request
    end

    def normalize_segment_ids(visit)
      visit.applied_segments.map(&:id).sort.join(',')
    end
  end
end
