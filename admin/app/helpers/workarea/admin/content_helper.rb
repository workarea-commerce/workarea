module Workarea
  module Admin
    module ContentHelper
      def current_system_page_content_for(name)
        @tmp ||= {}
        @tmp[name.to_s.systemize] ||= Content.for(name.to_s.systemize)
      end

      def layout_footer_area_id
        @layout_footer_area_id ||= begin
          content = Admin::ContentViewModel.wrap(
            current_system_page_content_for(:layout)
          )

          content.areas.find { |a| a =~ /footer/i }
        end
      end

      def render_content_areas(content)
        partial = "workarea/admin/content/types/_#{content.slug}"
        if lookup_context.find_all(partial).any?
          render(
            partial: "workarea/admin/content/types/#{content.slug}",
            locals: { content: content }
          )
        else
          render(
            partial: 'workarea/admin/content/types/generic',
            locals: { content: content }
          )
        end
      end

      def storefront_content_preview_path(content)
        return storefront.root_path unless content

        if content.layout? || content.home_page?
          storefront.root_path(draft_id: content.id)
        elsif content.contentable.is_a?(Content::Page)
          storefront.page_path(content.contentable, draft_id: content.id)
        elsif content.contentable.is_a?(Catalog::Category)
          storefront.category_path(content.contentable, draft_id: content.id)
        end
      end

      def options_for_category(category_id)
        return nil unless category_id.present?

        model = Catalog::Category.find(category_id)
        options_for_select({ model.name => model.id }, model.id)
      end

      def options_for_products(product_ids)
        return nil unless product_ids.present?

        products = Catalog::Product.find_ordered_for_display(product_ids)
        options_from_collection_for_select(products, 'id', 'name', product_ids)
      end

      def options_for_pages(page_ids)
        return nil unless page_ids.present?

        pages = Content::Page.find_ordered_for_display(page_ids)
        options_from_collection_for_select(pages, 'id', 'name', page_ids)
      end

      def block_delete_message(block)
        if current_release.present?
          t('workarea.admin.content.messages.delete_from_release', block_type: block.type.name, release: current_release.name)
        else
          t('workarea.admin.content.messages.delete', block_type: block.type.name)
        end
      end

      def preview_breakpoints
        Workarea.config.storefront_break_points.select do |name, size|
          name.to_s.in?(Workarea.config.content_preview_breakpoints)
        end
      end

      def color_picker_id(block, field)
        "#{block.id}-#{field.name.parameterize}-colors"
      end
    end
  end
end
