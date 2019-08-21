module Workarea
  module AssetEndpoints
    class Favicons < Base
      def result
        return unless Workarea.config.favicon_allowed_sizes.include?(params[:size])
        find_asset(params[:size])&.favicon(params[:size])
      end

      def ico
        find_asset('ico')&.favicon_ico
      end

      private

      def find_asset(type)
        Content::Asset.favicons(type).first ||
        Content::Asset.favicons.first ||
        Content::Asset.favicon_placeholder
      end
    end
  end
end
