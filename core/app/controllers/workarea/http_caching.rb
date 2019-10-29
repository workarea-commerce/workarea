module Workarea
  module HttpCaching
    extend ActiveSupport::Concern

    included do
      after_action :set_vary_headers
      helper_method :http_caching?
    end

    def cache_page
      unless current_user.try(:admin?)
        expires_in Workarea.config.cache_expirations.http_cache, public: true if flash.blank?
        request.session_options[:skip] = true
        @http_caching = true
      end
    end

    def http_caching?
      !!@http_caching
    end

    private

    def set_vary_headers
      response.headers['X-Requested-With'] = request.headers['X-Requested-With'] || ''
      response.headers['Vary'] = 'X-Requested-With, X-Workarea-Segments'
      fresh_when(last_modified: Time.current)
    end
  end
end
