module Workarea
  module Storefront
    module FaviconsHelper
      def favicon_tags
        warn <<~eos
          DEPRECATION WARNING: favicons_helper is deprecated, use
          `render 'workarea/storefront/favicons/tags'` directly in the layout
          instead
        eos
      end

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
