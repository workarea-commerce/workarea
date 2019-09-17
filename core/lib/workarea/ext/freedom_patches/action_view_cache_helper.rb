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
        super.tap { |result| result << cache_varies if cache_varies.present? }
      end

      def cache_varies
        request.env['workarea.cache_varies']
      end
    end
  end

  ActionView::Helpers.include(Helpers::WorkareaCache)
end
