module Workarea
  class Admin::CatalogVariantsController < Admin::ApplicationController
    required_permissions :catalog

    before_action :check_publishing_authorization
    before_action :find_product

    def index
      @variants = @product.variants.map do |variant|
        Admin::VariantViewModel.wrap(variant)
      end
    end

    def new
      @variant = @product.variants.new
    end

    def create
      @variant = @product.variants.new(params[:variant])
      set_details

      if @variant.save
        flash[:success] = t('workarea.admin.catalog_variants.flash_messages.saved')
        redirect_to catalog_product_variants_path(@product)
      else
        flash[:error] = t('workarea.admin.catalog_variants.flash_messages.changes_error')
        render :new
      end
    end

    def edit
      @variant = @product.variants.find(params[:id])
    end

    def update
      @variant = @product.variants.find(params[:id])
      set_details

      if @variant.update_attributes(params[:variant])
        flash[:success] = t('workarea.admin.catalog_variants.flash_messages.saved')
        redirect_to catalog_product_variants_path(@product)
      else
        flash[:error] = t('workarea.admin.catalog_variants.flash_messages.changes_error')
        render :edit
      end
    end

    def destroy
      @product.variants.find(params[:id]).destroy
      flash[:success] = t('workarea.admin.catalog_variants.flash_messages.removed')
      redirect_to catalog_product_variants_path(@product)
    end

    def details
      @values = Catalog::DetailsQueries.find_sku_details(
        params[:name],
        params[:q]
      )

      render 'workarea/admin/shared/values'
    end

    def move
      position_data = params.fetch(:positions, {})

      position_data.each do |variant_id, position|
        variant = @product.variants.find(variant_id)
        variant.position = position
      end

      @product.save!
      flash[:success] = t(
        'workarea.admin.catalog_variants.flash_messages.sorting_saved'
      )
      head :ok
    end

    private

    def find_product
      model = Catalog::Product.find_by(slug: params[:catalog_product_id])
      @product = Admin::ProductViewModel.new(model, view_model_options)
    end

    def set_details
      @variant.details = HashUpdate.new(
        original: @variant.details,
        adds: params[:new_details],
        updates: params[:details],
        removes: params[:details_to_remove]
      ).result
    end
  end
end
