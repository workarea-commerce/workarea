module Workarea
  class Admin::CreateContentPagesController < Admin::ApplicationController
    required_permissions :store

    before_action :find_page
    before_action :find_taxon, only: [:taxonomy, :save_taxonomy]
    before_action :allow_publishing!, only: :content

    def index
      render :setup
    end

    def create
      @page.attributes = params[:page]

      if @page.save
        flash[:success] = t('workarea.admin.create_content_pages.flash_messages.saved')
        redirect_to content_create_content_page_path(@page)
      else
        render :setup, status: :unprocessable_entity
      end
    end

    def edit
      render :setup
    end

    def content
      model = Content.for(@page.model)
      @content = Admin::ContentViewModel.new(model, view_model_options)
    end

    def taxonomy
    end

    def save_taxonomy
      save = SaveTaxonomy.new(@taxon, params)
      save.perform
      flash[:success] = t('workarea.admin.create_content_pages.flash_messages.taxonomy_saved')

      if save.top_level?
        redirect_to navigation_create_content_page_path(@page)
      else
        redirect_to publish_create_content_page_path(@page)
      end
    end

    def navigation
    end

    def save_navigation
      if params[:create_menu].to_s =~ /true/
        Navigation::Menu.create!(taxon: @page.taxon)
        flash[:success] = t('workarea.admin.create_content_pages.flash_messages.navigation_saved')
      end

      redirect_to publish_create_content_page_path(@page)
    end

    def publish
    end

    def save_publish
      publish = SavePublishing.new(@page, params)

      if publish.perform
        flash[:success] = t('workarea.admin.create_content_pages.flash_messages.created')
        redirect_to content_page_path(@page)
      else
        flash[:error] = publish.errors.full_messages
        render :publish
      end
    end

    private

    def find_page
      model = if params[:id].present?
                Content::Page.find_by(slug: params[:id])
              else
                Content::Page.new(params[:page])
              end

      @page = Admin::PageViewModel.new(model, view_model_options)
    end

    def find_taxon
      @taxon = SaveTaxonomy.build(@page.model)
    end
  end
end
