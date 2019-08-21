module Workarea
  module Admin
    class PricingSkusController < Admin::ApplicationController
      required_permissions :catalog

      before_action :check_publishing_authorization
      before_action :find_sku, except: :index
      after_action :track_index_filters, only: :index

      def index
        search_params = if product
                          view_model_options.merge(q: product.skus.join(' '))
                        else
                          view_model_options
                        end

        search = Search::AdminPricingSkus.new(search_params)
        @search = SearchViewModel.new(search, search_params)
      end

      def show
        @sku = PricingSkuViewModel.new(@sku)
      end

      def create
        @sku.prices = price_params

        if @sku.save
          flash[:success] =
            t('workarea.admin.pricing_skus.saved', sku: @sku.id)
          redirect_to pricing_sku_path(@sku)
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        @sku = PricingSkuViewModel.new(@sku)
      end

      def update
        if @sku.update_attributes(sku_params)
          flash[:success] =
            t('workarea.admin.pricing_skus.saved', sku: @sku.id)
          redirect_to pricing_sku_path(@sku)
        else
          @sku = PricingSkuViewModel.new(@sku)
          render :edit, status: :unprocessable_entity
        end
      end

      private

      def matching_sku
        if params[:q].present?
          @matching_sku ||= Pricing::Sku.where(id: params[:q]).first
        end
      end

      def product
        if params[:product_id].present?
          Catalog::Product.find(params[:product_id])
        end
      end

      def sku_params
        # blank strings convert to $0 when to_money is called
        (params[:sku] || {}).transform_values(&:presence)
      end

      def price_params
        (params[:prices] || [])
          .reject { |price| price[:regular].blank? }
          .map    { |price| price.to_h }
          .map    { |price| price.transform_values(&:presence) }
      end

      def find_sku
        @sku = if params[:id].present?
                 Pricing::Sku.find_or_create_by(id: params[:id])
               else
                 Pricing::Sku.new(sku_params)
               end
      end
    end
  end
end
