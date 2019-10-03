module Workarea
  module Storefront
    module FaviconsHelper
      # TODO remove in v3.6
      def favicon_tags; end
      Workarea.deprecation.deprecate_methods(
        FaviconsHelper,
        favicon_tags: "Use `render 'workarea/storefront/favicons/tags'`"
      )

      def favicons_present?
        Content::Asset.favicons.count.positive?
      end

      def favicons_path(size, options = {})
        image_url(dynamic_favicons_path(size, options))
      end

      def favicon_path(options = {})
        image_url(dynamic_favicon_path(options))
      end
    end
  end
end
