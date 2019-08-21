module Workarea
  module Admin
    class ToolbarController < Admin::ApplicationController
      include Storefront::CurrentCheckout
      layout false

      def show
        if params[:id].present?
          model = GlobalID::Locator.locate(params[:id])
          @model = wrap_in_view_model(model, view_model_options)
          @content = Content.for(model) if model.is_a?(Contentable)
        end
      end
    end
  end
end
