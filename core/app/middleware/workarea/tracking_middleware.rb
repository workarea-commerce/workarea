module Workarea
  class TrackingMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      if request.path =~ /(jpe?g|png|ico|gif|css|js)$/
        @app.call(env)
      else
        env['workarea.visit'] = Visit.new(env)

        status, headers, body = @app.call(env)

        unless Rails.env.production?
          headers['X-Workarea-Segments'] = env['workarea.visit'].segments.map(&:id).join(',')
          headers['X-Workarea-Cache-Varies'] = env['workarea.visit'].varies.to_s
        end

        [status, headers, body]
      end
    end
  end
end
