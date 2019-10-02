module Workarea
  module Admin
    class CatalogCategoriesController < Admin::ApplicationController
      required_permissions :catalog

      before_action :check_publishing_authorization
      before_action :find_category, except: :index
      after_action :track_index_filters, only: :index

      def index
        search = Search::AdminCategories.new(
          params.merge(
            autocomplete: request.xhr?,
            exclude_ids: exclude_ids
          )
        )

        @search = SearchViewModel.new(search, view_model_options)
      end

      def show
      end

      def edit
      end

      def update
        set_range_facets
        @category.save

        if @category.update_attributes(params[:category])
          flash[:success] = t('workarea.admin.catalog_categories.flash_messages.saved')
          redirect_to catalog_category_path(@category)
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def insights
      end

      def destroy
        @category.destroy
        flash[:success] = t('workarea.admin.catalog_categories.flash_messages.removed')
        redirect_to catalog_categories_path
      end

      private

      def exclude_ids
        if params[:exclude_ids].blank?
          []
        else
          Catalog::Category.in(id: params[:exclude_ids]).map { |c| Search::Admin.for(c).id }
        end
      end

      def find_category
        if params[:id].present?
          @category = Catalog::Category.find_by(slug: params[:id])
        else
          @category = Catalog::Category.new(params[:category])
        end

        @category = CategoryViewModel.new(@category, view_model_options)
      end

      def set_range_facets
        @category.range_facets = CleanRangeFacets.new(params[:range_facets]).result
      end
    end
  end
end
