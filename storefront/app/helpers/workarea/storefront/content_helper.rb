module Workarea
  module Storefront
    module ContentHelper
      include AnalyticsHelper

      def render_content_block(block)
        content_tag(
          :div,
          render(partial: block.partial, locals: block.locals),
          class: content_block_classes_for(block),
          id: dom_id(block),
          data: {
            analytics: content_block_analytics_data(block),
            hidden_block_css_content: t('workarea.storefront.content_blocks.hidden_block_css_content')
          }
        )
      end

      def render_content_blocks(blocks)
        if current_user.try(:admin?)
          render_content_blocks_without_cache(blocks)
        else
          Rails.cache.fetch(
            blocks.map(&:cache_key).push(cache_varies).join('/'),
            expires_in: Workarea.config.cache_expirations.render_content_blocks
          ) { render_content_blocks_without_cache(blocks) }
        end
      end

      def render_content_blocks_without_cache(blocks)
        blocks.inject('') do |result, block|
          result << render_content_block(block)
          result
        end.html_safe
      end

      def content_block_classes_for(block)
        classes = []
        classes << content_block_visibility_classes_for(block)
        classes << content_block_type_class_for(block)
      end

      def content_block_visibility_classes_for(block)
        block
          .hidden_breakpoints
          .map { |n| "content-block--hidden-for-#{n.dasherize}" }
          .push('content-block')
          .join(' ')
      end

      def content_block_type_class_for(block)
        "content-block--#{block.type_id.to_s.dasherize}"
      end

      def render_image_with_link(src, alt, css_block, url)
        image = image_tag(src, alt: alt, class: "#{css_block}__image")

        if url.present?
          link_to(image, url, class: "#{css_block}__image-link")
        else
          image
        end
      end

      def intrinsic_ratio_frame_styles(asset)
        return if asset.inverse_aspect_ratio.blank?
        "padding: 0 0 #{asset.inverse_aspect_ratio * 100}%; height: 0;"
      end
    end
  end
end
