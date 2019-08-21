module Workarea
  class EnforceHostMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)

      if enforce_host?(request)
        Rails.logger.warn "Host enforced: expected #{Workarea.config.host}, got #{request.host}"
        redirect("#{request.scheme}://#{Workarea.config.host}#{request.fullpath}")
      else
        @app.call(env)
      end
    end

    private

    def enforce_host?(request)
      Workarea.config.enforce_host &&
        request.host != Workarea.config.host &&
        !skip_enforce_host?(request)
    end

    def skip_enforce_host?(request)
      return false if Workarea.config.skip_enforce_host.blank?
      Workarea.config.skip_enforce_host.call(request)
    end

    def redirect(location)
      [
        301,
        { 'Location' => location, 'Content-Type' => 'text/html' },
        ['Moved Permanently']
      ]
    end
  end
end
