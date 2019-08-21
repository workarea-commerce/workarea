module Workarea
  module Admin
    class CreatePricingDiscountsController < Admin::ApplicationController
      required_permissions :marketing

      before_action :find_discount

      def index
        render :setup
      end

      def create
        @discount.attributes = params[:discount] unless @discount.new_record?

        if @discount.save
          flash[:success] = t('workarea.admin.create_pricing_discounts.flash_messages.saved')
          redirect_to publish_create_pricing_discount_path(@discount, type: params[:type])
        else
          render :rules, status: :unprocessable_entity
        end
      end

      def edit
        render :setup
      end

      def details
      end

      def rules
      end

      def publish
      end

      def save_publish
        publish = SavePublishing.new(@discount, params)

        if publish.perform
          flash[:success] = t('workarea.admin.create_pricing_discounts.flash_messages.created')
          redirect_to pricing_discount_path(@discount)
        else
          flash[:error] = publish.errors.full_messages
          render :publish
        end
      end

      def destroy
        @discount.destroy
        redirect_to create_pricing_discounts_path
      end

      private

      def find_discount
        model = if params[:id].present?
                  Pricing::Discount.find(params[:id])
                elsif params[:type].present?
                  NewDiscount.new_discount(params[:type], params[:discount])
                else
                  Pricing::Discount.new(params[:discount])
                end

        @discount = DiscountViewModel.wrap(model, view_model_options)
      end
    end
  end
end
