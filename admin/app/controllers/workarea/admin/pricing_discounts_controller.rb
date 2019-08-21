module Workarea
  class Admin::PricingDiscountsController < Admin::ApplicationController
    required_permissions :marketing

    before_action :check_publishing_authorization
    before_action :find_discount, except: :index
    after_action :track_index_filters, only: :index

    def index
      search = Search::AdminDiscounts.new(
        params.merge(autocomplete: request.xhr?)
      )

      @search = Admin::DiscountSearchViewModel.new(search, view_model_options)
    end

    def show
      @discount = Admin::DiscountViewModel.wrap(@discount, view_model_options)
    end

    def edit
      @discount = Admin::DiscountViewModel.wrap(@discount, view_model_options)
    end

    def update
      if @discount.update_attributes(params[:discount])
        flash[:success] = t('workarea.admin.pricing_discounts.flash_messages.saved')
        redirect_to pricing_discount_path(@discount)
      else
        @discount = Admin::DiscountViewModel.wrap(@discount, view_model_options)
        render params[:template] || :edit, status: :unprocessable_entity
      end
    end

    def insights
      @discount = Admin::DiscountViewModel.new(@discount, view_model_options)
    end

    def rules
      @discount = Admin::DiscountViewModel.wrap(@discount, view_model_options)
    end

    def destroy
      @discount.destroy
      flash[:success] = t('workarea.admin.pricing_discounts.flash_messages.removed')
      redirect_to pricing_discounts_path
    end

    private

    def find_discount
      # TODO: v4 dry up view model wrapping in this file
      @discount = Pricing::Discount.find(params[:id])
    end
  end
end
