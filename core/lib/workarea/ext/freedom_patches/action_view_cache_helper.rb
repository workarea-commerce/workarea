module ActionView
  module Helpers
    module WorkareaCache
      def cache(*)
        if logged_in? && current_user.admin?
          yield
          nil
        else
          super
        end
      end

      def cache_fragment_name(*)
        result = super

        if request.env['workarea.cache_varies'].present?
          result << request.env['workarea.cache_varies']
        end

        result
      end
    end
  end

  ActionView::Helpers.include(Helpers::WorkareaCache)
end
