module Workarea
  module Admin
    class TaxRatesController < Admin::ApplicationController
      required_permissions :catalog

      before_action :find_category
      before_action :find_rate, only: [:edit, :update, :destroy]

      def index
        @rates = @category.rates.search(params[:q])
          .page(params[:page])
          .order_by(find_sort(Tax::Rate))
      end

      def new
        @rate = @category.rates.new
      end

      def create
        if @category.rates.new(rate_params).save
          flash[:success] = t('workarea.admin.tax_rates.flash_messages.saved')
          redirect_to tax_category_rates_path
        else
          flash[:error] = t('workarea.admin.tax_rates.flash_messages.changes_error')
          render :new
        end
      end

      def edit
      end

      def update
        if @rate.update_attributes(rate_params)
          flash[:success] = t('workarea.admin.tax_rates.flash_messages.saved')
          redirect_to tax_category_rates_path
        else
          flash[:error] = t('workarea.admin.tax_rates.flash_messages.changes_error')
          render :edit
        end
      end

      def destroy
        @rate.destroy

        flash[:success] = t('workarea.admin.tax_rates.flash_messages.removed')
        redirect_to tax_category_rates_path
      end

      private

      def find_category
        model = Tax::Category.find(params[:tax_category_id])
        @category = TaxCategoryViewModel.wrap(model, view_model_options)
      end

      def find_rate
        @rate = @category.rates.find(params[:id])
      end

      def percentage_fields
        %w[country_percentage region_percentage postal_code_percentage]
      end

      def rate_params
        params[:rate].to_h.map do |field, value|
          if field.in?(percentage_fields) && value.to_f > 0
            value = value.to_f / 100
          end

          [field, value]
        end.to_h
      end
    end
  end
end
