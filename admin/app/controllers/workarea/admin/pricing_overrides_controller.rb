module Workarea
  module Admin
    class PricingOverridesController < Admin::ApplicationController
      required_permissions :orders_manager

      before_action :find_override
      before_action :find_order

      def edit; end

      def update
        if @override.update(override_params)
          create_comment if params[:comment].present? && !request.xhr?
          update_pricing

          flash[:success] = t('workarea.admin.pricing_overrides.flash_messages.success')
          request.xhr? ? render(:edit) : redirect_to(storefront.cart_path)
        else
          flash[:error] = t('workarea.admin.pricing_overrides.flash_messages.error')
          render :edit
        end
      end

      private

      def find_override
        @override = Pricing::Override.find_or_create_by(id: params[:id])
      end

      def find_order
        @order = Admin::OrderViewModel.new(Order.find(params[:id]))
      end

      def override_params
        PricingOverrideParams.new(
          params[:override].to_unsafe_h,
          current_admin
        ).to_h
      end

      def create_comment
        @order.model.comments.create!(
          body: params[:comment],
          author_id: current_user.id
        )
      end

      def update_pricing
        shippings = Shipping.by_order(params[:id])
        Pricing.perform(@order.model, shippings)
      end
    end
  end
end
