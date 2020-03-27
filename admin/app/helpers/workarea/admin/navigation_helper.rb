module Workarea
  module Admin
    module NavigationHelper
      def navigation_link_classes(url = nil)
        return 'primary-nav__link' if url.blank?

        classes = ['primary-nav__link']
        classes << 'primary-nav__link--active' if request.fullpath == url
        classes.join(' ')
      end

      def todays_orders_path
        orders_path(
          placed_at_greater_than: Time.current.to_s(:date_only),
          placed_at_less_than: Time.current.to_s(:date_only)
        )
      end

      def yesterdays_orders_path
        orders_path(
          placed_at_greater_than: 1.day.ago.to_s(:date_only),
          placed_at_less_than: 1.day.ago.to_s(:date_only)
        )
      end

      def customers_path
        users_path(role: %w(Customer))
      end

      def administrators_path
        users_path(role: %w(Administrator))
      end

      # TODO remove in v3.6, no longer used
      def todays_signups_path
        users_path(
          created_at_greater_than: Time.current.to_s(:date_only),
          created_at_less_than: Time.current.to_s(:date_only)
        )
      end

      def link_to_index_for(model)
        unfiltered_path = index_url_for(model)

        last_index_path = session[:last_index_path].to_s
        title_name = model.model_name.human.downcase.pluralize
        show_last_index_path = last_index_path.present? &&
                                last_index_path != unfiltered_path &&
                                last_index_path.include?(unfiltered_path)

        if show_last_index_path
          link_to("↑ #{t('workarea.admin.shared.primary_nav.back_filtered_link', resource: title_name)}", session[:last_index_path])
        else
          link_to("↑ #{t('workarea.admin.shared.primary_nav.back_link', resource: title_name)}", unfiltered_path)
        end

      rescue ActionController::UrlGenerationError
        # It's ok if we can't render back to index, better to allow page to show
      end

      def index_url_for(class_or_model, options = {})
        url_for(
          options.reverse_merge(
            controller: "workarea/admin/#{class_or_model.model_name.route_key}",
            action: 'index'
          )
        )

      rescue ActionController::UrlGenerationError
        nil
      end
    end
  end
end
