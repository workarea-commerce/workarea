module Workarea
  # This class exists to disable all HTTP caching in the test envionrment.
  # There's no way to disable caching in headless Chrome so this ensures
  # reliability with running tests there.
  class StripHttpCachingMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)

      unless Workarea.config.strip_http_caching_in_tests
        return [status, headers, body]
      end

      headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
      headers['Expires'] = '0'

      [status, headers, body]
    end
  end
end
