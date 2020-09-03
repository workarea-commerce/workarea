module Workarea
  module Storefront
    module DisplayContent
      delegate :css, :javascript, :head_content, :content_security_policy,
        to: :content, allow_nil: true

      def browser_title
        if content && content.browser_title.present?
          content.browser_title
        elsif model.respond_to?(:name)
          name
        end
      end

      def meta_description
        return content.meta_description unless content.meta_description.blank?

        t(
          'workarea.storefront.layouts.default_meta_description',
          site_name: Workarea.config.site_name
        )
      end

      def open_graph_asset
        @open_graph_asset ||=
          if content.open_graph_asset_id.present?
            Content::Asset.find(content.open_graph_asset_id)
          elsif (og_default = Content::Asset.open_graph_default).present?
            og_default
          else
            Content::Asset.open_graph_placeholder
          end
      rescue Mongoid::Errors::DocumentNotFound
        @open_graph_asset = Content::Asset.open_graph_placeholder
      end

      def content
        @content ||= Content.for(content_lookup)
      end

      def content_blocks
        content_blocks_for(:default)
      end

      def content_blocks_for(area)
        return [] unless content.present?
        blocks = content.blocks_for(area).select(&:active?)
        ContentBlockViewModel.wrap(blocks, options)
      end

      private

      def content_lookup
        model
      end
    end
  end
end
