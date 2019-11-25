module Workarea
  class Admin::ContentAssetsController < Admin::ApplicationController
    required_permissions :store

    before_action :find_asset, only: [:show, :edit, :update, :destroy]
    before_action :new_asset, only: [:new, :create]
    after_action :track_index_filters, only: :index

    def index
      DirectUpload.ensure_cors!(request.url) if Configuration::S3.configured?

      search = Search::AdminAssets.new(params)
      @search = Admin::SearchViewModel.new(search, view_model_options)
    end
    alias_method :insert, :index

    def tags
      @tags = if Content::Asset.empty?
                []
              else
                Content::Asset.all_tags(type: params[:type])
              end
    end

    def show
    end

    def new; end

    def create
      if @asset.save
        flash[:success] = t('workarea.admin.content_assets.flash_messages.created')
        redirect_to content_asset_path(@asset)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @asset.update_attributes(params[:asset])
        flash[:success] = t('workarea.admin.content_assets.flash_messages.saved')
        redirect_to content_asset_path(@asset)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @asset.destroy
      flash[:success] = t('workarea.admin.content_assets.flash_messages.removed')
      redirect_to content_assets_path
    end

    private

    def new_asset
      @asset = Content::Asset.new(params[:asset])
    end

    def find_asset
      @asset = Admin::AssetViewModel.new(Content::Asset.find(params[:id]))
    end
  end
end
