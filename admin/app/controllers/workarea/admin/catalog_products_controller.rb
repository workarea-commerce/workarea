module Workarea
  class Admin::CatalogProductsController < Admin::ApplicationController
    required_permissions :catalog

    before_action :check_publishing_authorization
    before_action :find_product, except: :index
    after_action :track_index_filters, only: :index

    def index
      search = Search::AdminProducts.new(
        params.merge(autocomplete: request.xhr?)
      )

      @search = Admin::SearchViewModel.new(search, view_model_options)
    end

    def show; end

    def update
      set_details
      set_filters

      if @product.update_attributes(params[:product])
        flash[:success] = t('workarea.admin.catalog_products.flash_messages.saved')
        redirect_to catalog_product_path(@product)
      else
        flash[:error] = @product.errors.full_messages
        render :edit, status: :unprocessable_entity
      end
    end

    def content
    end

    def insights
    end

    def destroy
      @product.destroy
      flash[:success] = t('workarea.admin.catalog_products.flash_messages.deleted')
      redirect_to catalog_products_path
    end

    def filters
      @values = Catalog::DetailsQueries.find_filters(params[:name], params[:q])
      render 'workarea/admin/shared/values'
    end

    def details
      @values = Catalog::DetailsQueries.find_details(params[:name], params[:q])
      render 'workarea/admin/shared/values'
    end

    private

    def find_product
      model = if params[:id].present?
                Catalog::Product.find_by(slug: params[:id])
              else
                Catalog::Product.new(params[:product])
              end

      @product = Admin::ProductViewModel.new(model, view_model_options)
    end

    def set_details
      @product.details = HashUpdate.new(
        original: @product.details,
        adds: params[:new_details],
        updates: params[:details],
        removes: params[:details_to_remove]
      ).result
    end

    def set_filters
      @product.filters = HashUpdate.new(
        original: @product.filters,
        adds: params[:new_filters],
        updates: params[:filters],
        removes: params[:filters_to_remove]
      ).result
    end
  end
end
