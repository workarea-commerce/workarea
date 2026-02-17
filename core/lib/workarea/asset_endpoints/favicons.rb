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
        # Mongoid::Document::Taggable's `tagged_with` scope has shown
        # inconsistent behavior under newer Ruby/Mongoid combos in test,
        # causing the generic fallback (`tagged_with('favicon')`) to return no
        # results even when a favicon asset exists. Query the tags array
        # directly for deterministic behavior.
        Content::Asset.where(tags: "favicon-#{type}").first ||
          Content::Asset.where(tags: 'favicon').first ||
          Content::Asset.favicon_placeholder
      end
    end
  end
end
