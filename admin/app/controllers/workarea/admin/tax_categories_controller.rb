module Workarea
  module Admin
    class TaxCategoriesController < Admin::ApplicationController
      required_permissions :settings
      before_action :find_category, except: :index

      def index
        @categories = Tax::Category.all
      end

      def show
      end

      def new; end

      def edit; end

      def create
        if @category.save
          flash[:success] = t('workarea.admin.tax_categories.flash_messages.created')
          redirect_to tax_category_path(@category)
        else
          render :new
        end
      end

      def update
        if @category.update_attributes(params[:category])
          flash[:success] = t('workarea.admin.tax_categories.flash_messages.saved')
          redirect_to tax_category_path(@category)
        else
          render :edit
        end
      end

      def destroy
        @category.destroy
        flash[:success] = t('workarea.admin.tax_categories.flash_messages.removed')
        redirect_to tax_categories_path
      end

      private

      def find_category
        model = if params[:id].present?
                  Tax::Category.find(params[:id])
                else
                  Tax::Category.new(params[:category])
                end

        @category = TaxCategoryViewModel.wrap(model, view_model_options)
      end
    end
  end
end
