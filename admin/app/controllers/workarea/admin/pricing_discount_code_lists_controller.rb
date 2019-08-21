module Workarea
  class Admin::PricingDiscountCodeListsController < Admin::ApplicationController
    required_permissions :marketing

    before_action :set_code_list, except: :index

    def index
      @code_lists = Pricing::Discount::CodeList.all.page(params[:page])
    end

    def show; end

    def promo_codes; end

    def new; end

    def create
      if @code_list.save
        flash[:success] = t('workarea.admin.pricing_discount_code_lists.flash_messages.generated')
        redirect_to pricing_discount_code_list_path(@code_list)
      else
        flash[:error] = t('workarea.admin.pricing_discount_code_lists.flash_messages.saved_error')
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @code_list.update(params[:code_list])
        flash[:success] = t('workarea.admin.pricing_discount_code_lists.flash_messages.updated')
        redirect_to pricing_discount_code_list_path(@code_list)
      else
        flash[:error] = t('workarea.admin.pricing_discount_code_lists.flash_messages.saved_error')
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @code_list.destroy
      flash[:success] = t('workarea.admin.pricing_discount_code_lists.flash_messages.removed')
      redirect_to pricing_discount_code_lists_path
    end

    private

    def set_code_list
      model =
        if params[:id].present?
          Pricing::Discount::CodeList.find(params[:id])
        else
          Pricing::Discount::CodeList.new(params[:code_list])
        end

      @code_list = Admin::CodeListViewModel.wrap(model, view_model_options)
    end
  end
end
