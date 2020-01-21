module Workarea
  module Storefront
    module NavigationHelper
      def navigation_menus
        @navigation_menus ||= Navigation::Menu
                                .all
                                .includes(:content)
                                .sort_by(&:position)
                                .select(&:active?)
      end

      def navigation_menu_item_data_attribute(menu)
        return if menu.content.blank?
        return if ContentViewModel.new(menu.content).content_blocks.blank?

        {
          primary_nav_content: menu.id,
          action: %w(
            mouseenter->navigation#show
            touchstart->navigation#show
            touchstart->navigation#touch
          ).join(' ')
        }
      end

      def mobile_nav_return_path
        uri = URI.parse(
          params[:return_to].presence ||
          request.referer.presence ||
          root_url
        )

        uri.path
      end

      def link_selected?(taxon)
        !!@breadcrumbs.try(:selected?, taxon)
      end

      def left_navigation
        return '' unless @breadcrumbs.present?

        taxon = @breadcrumbs[-2] || @breadcrumbs.last
        return '' unless taxon.present?

        if taxon.has_children?
          selected_child_taxon = taxon.children.detect do |child|
            link_selected?(child)
          end
          render 'workarea/storefront/shared/left_navigation',
            taxon: taxon,
            selected_child_taxon: selected_child_taxon
        else
          ''
        end
      end

      def link_to_menu(menu)
        styles = 'primary-nav__link'
        styles << ' primary-nav__link--selected' if link_selected?(menu.taxon)
        options = {
          class: styles,
          data: {
            analytics: primary_navigation_analytics_data(menu.taxon).to_json
          }
        }

        if menu.taxon.placeholder?
          content_tag :span, menu.name, options
        else
          link_to menu.name, storefront_path_for(menu.taxon), options
        end
      end

      def storefront_path_for(taxon)
        if taxon.url?
          taxon.url
        elsif taxon.root?
          respond_to?(:storefront) ? storefront.root_path : root_path
        elsif taxon.search_results?
          search_path(taxon.navigable.params)
        elsif taxon.navigable?
          send("#{taxon.resource_name}_path", taxon.navigable_slug)
        end
      end

      def storefront_url_for(taxon)
        path = storefront_path_for(taxon)

        return if path.blank?

        protocol = Rails.application.config.force_ssl ? 'https' : 'http'
        "#{protocol}://#{Workarea.config.host}/#{path.sub(/^\//, '')}"
      end


      # Generate a cache key for a taxon's left navigation. Uses the
      # `:selected` taxon in the cache key if a given node is selected,
      # otherwise just appends the `section` argument onto the `taxon`'s
      # cache key.
      #
      # @param [Symbol] section - Section of the page we are caching
      # @option [Workarea::Navigation::Taxon] selected - Selected child taxon
      # @return [Array] Elements of a given cache key that Rails will
      # expand.
      def taxon_cache_key(taxon, section = nil, selected: nil)
        selected_cache_key = "selected:#{selected.cache_key}" if selected.present?
        fragment = section&.to_s

        [taxon.cache_key, selected_cache_key, fragment]
      end
    end
  end
end
