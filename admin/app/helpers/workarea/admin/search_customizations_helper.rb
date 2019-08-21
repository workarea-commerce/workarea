module Workarea
  module Admin
    module SearchCustomizationsHelper
      def icon_for_search_middleware_status(status)
        if status == :ignore
          '✗'
        elsif status == :last
          '✓'
        else
          '↓'
        end
      end

      def search_middleware_display_name(klass)
        klass.name.demodulize.underscore.humanize
      end
    end
  end
end
