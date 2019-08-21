module Workarea
  class Storefront::Users::OrdersController < Storefront::ApplicationController
    before_action :require_login

    def index
      models = Order.recent(
        current_user.id,
        Workarea.config.storefront_user_order_display_count
      )
      statuses = Fulfillment.find_statuses(*models.map(&:id))

      @orders = models.map do |order|
        Storefront::OrderViewModel.new(
          order,
          fulfillment_status: statuses[order.id]
        )
      end
    end

    def show
      model = Order.find(params[:id])

      if model.user_id != current_user.id.to_s
        head :forbidden and return
      else
        @order = Storefront::OrderViewModel.new(model)
      end
    end
  end
end
