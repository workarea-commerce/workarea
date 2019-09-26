module Workarea
  module Admin
    class FulfillmentTokensController < Admin::ApplicationController
      required_permissions :catalog

      before_action :find_sku
      before_action :find_token, only: :update

      def index
        @tokens =
          Fulfillment::Token
            .for_sku(@sku.id)
            .page(params[:page])
            .per(Workarea.config.per_page)
            .order_by(find_sort(Fulfillment::Token))
      end

      def create
        @token = Fulfillment::Token.new(sku: @sku.id)

        if @token.save
          flash[:success] = t('workarea.admin.fulfillment_tokens.flash_messages.created')
        else
          flash[:error] = t('workarea.admin.fulfillment_tokens.flash_messages.error')
        end

        redirect_to fulfillment_sku_tokens_path(@sku, new_token: @token.id)
      end

      def update
        result = @token.update(params[:token])

        if result && @token.enabled?
          flash[:success] = t('workarea.admin.fulfillment_tokens.flash_messages.enabled')
        elsif result
          flash[:success] = t('workarea.admin.fulfillment_tokens.flash_messages.disabled')
        else
          flash[:error] = t('workarea.admin.fulfillment_tokens.flash_messages.update_failed')
        end

        redirect_back_or fulfillment_sku_tokens_path(@sku)
      end

      private

      def find_sku
        model = Fulfillment::Sku.find(params['fulfillment_sku_id'])
        @sku = Admin::FulfillmentSkuViewModel.wrap(model, view_model_options)
      end

      def find_token
        @token = Fulfillment::Token.find(params[:id])
      end
    end
  end
end
