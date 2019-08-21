module Workarea
  module Admin
    class PricingDiscountRedemptionsController < Admin::ApplicationController
      required_permissions :marketing

      def index
        model = Pricing::Discount.find(params[:pricing_discount_id])
        @discount = DiscountViewModel.wrap(model, view_model_options)
        @redemptions = model.redemptions.recent.page(params[:page])
      end
    end
  end
end
