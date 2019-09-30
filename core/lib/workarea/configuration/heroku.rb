module Workarea
  module Configuration
    module Heroku
      extend self

      APP_NAME = ENV["HEROKU_APP_NAME"]

      def load
        Workarea.config.site_name = APP_NAME
        Workarea.config.host = "#{APP_NAME}.herokuapp.com"
      end
    end
  end
end
