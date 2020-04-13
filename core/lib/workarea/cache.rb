module Workarea
  module Cache
    class RackCacheKey < Rack::Cache::Key
      def generate
        "#{super}:#{@request.env['workarea.cache_varies']}"
      end
    end

    class Varies
      attr_reader :visit
      delegate_missing_to :visit

      # This allows varying the HTTP and fragment caching on cookies, session or
      # other request-based info (like headers). This is useful when you'd like
      # to vary responses based on some data the browser won't be sending - like
      # what segments a request will be in or geolocation. You'll want to be
      # VERY careful when doing this - remember this block will be run on
      # _every_ request, so doing expensive things like DB queries is
      # discouraged.
      #
      # The source of data on which you can vary is an ActionDispatch::Request:
      # http://api.rubyonrails.org/classes/ActionDispatch/Request.html
      #
      # This allows you to access headers, session, cookies, IP address, etc.
      # Within this block, all missing method calls are delegated to an instance
      # of ActionDispatch::Request. You also have access to an instance of
      # Workarea::Geolocation to work with as well (available by calling
      # geolocation).
      #
      #
      # Here are some examples of how you might use this varying:
      #
      #
      # Retailer wants separate content for each region:
      #    Workarea::Cache::Varies.on { geolocation.region }
      #
      #
      # Some users have custom price lists:
      #    # in app/controllers/workarea/application_controller.decorator
      #    after_action :set_price_list
      #
      #    def set_price_list
      #      session[:price_list_id] = current_user.try(:price_list_id)
      #    end
      #
      #    # in config/initializers/workarea.rb
      #    Workarea::Cache::Varies.on { session[:price_list_id] }
      #
      #
      # A segmentation plugin sets segments based on the current user:
      #    # in app/controllers/workarea/application_controller.decorator
      #    after_action :set_segment_ids
      #
      #    def set_segment_ids
      #      session[:segment_ids] = Segments.find_matching(current_user).map(&:id)
      #    end
      #
      #    # in config/initializers/workarea.rb
      #    Workarea::Cache::Varies.on { session[:segment_ids].sort.join }
      #
      #
      def self.on(&block)
        Workarea.config.cache_varies ||= []
        Workarea.config.cache_varies << block
      end

      def initialize(visit, varies = Workarea.config.cache_varies)
        @visit = visit
        @varies = varies || []
      end

      def to_s
        @to_s ||= ([I18n.locale] + @varies.map { |v| visit.instance_exec(&v).to_s }).join(':')
      end
    end
  end
end
