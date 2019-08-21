module Workarea
  module Admin
    module OrdersHelper
      def render_order_timeline_entry(entry)
        render "workarea/admin/orders/timeline/#{entry.slug}", entry: entry

      rescue ActionView::MissingTemplate
        '' # we don't want to render anything if the partial is missing
      end

      def state_indicator_class(status)
        state = Workarea.config.status_state_indicators[status]
        "state--#{state}" if state.present?
      end
    end
  end
end
