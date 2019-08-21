module Workarea
  class Admin::OrdersController < Admin::ApplicationController
    required_permissions :orders

    before_action :find_order, except: :index
    after_action :track_index_filters, only: :index

    def index
      search = Search::AdminOrders.new(
        params.merge(autocomplete: request.xhr?)
      )

      @search = Admin::OrderSearchViewModel.new(search, view_model_options)
    end

    def show
    end

    def timeline
    end

    def fraud
    end

    private

    def find_order
      @order = Admin::OrderViewModel.new(Order.find(params[:id]))
    end
  end
end
