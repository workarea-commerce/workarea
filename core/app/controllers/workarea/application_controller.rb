module Workarea
  class ApplicationController < ActionController::Base
    include I18n::DefaultUrlOptions
    protect_from_forgery

    before_action :set_locale
    after_action :set_flash_header

    # Cache templates within the scope of a request for development
    if Rails.env.development?
      prepend_before_action { ActionView::Resolver.caching = true }
      after_action { ActionView::Resolver.caching = false }
    end

    helper_method :current_location
    helper :local_time

    def default_url_options(*)
      super.merge(host: Workarea.config.host)
    end

    def current_location
      @current_location ||= Geolocation.new(request.env, request.remote_ip)
    end

    def view_model_options
      params.to_unsafe_h
    end

    private

    def set_locale
      I18n.locale = params[:locale] || I18n.default_locale
    end

    def set_flash_header
      messages = flash.map { |k, v| [k, ERB::Util.h(v)] }
      response.headers['X-Flash-Messages'] = Hash[messages].to_json
      flash.discard if request.xhr? && !response.redirect?
    end
  end
end
