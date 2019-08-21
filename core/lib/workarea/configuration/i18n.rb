module Workarea
  module Configuration
    module I18n
      extend self

      def load
        Rails.application.config.i18n.available_locales = [:en]
        Rails.application.config.i18n.default_locale = :en
      end
    end
  end
end
