module Workarea
  class Admin::ContentPagesController < Admin::ApplicationController
    required_permissions :store

    before_action :check_publishing_authorization
    before_action :find_page, except: :index
    before_action :find_content, except: :index
    after_action :track_index_filters, only: :index

    def index
      search = Search::AdminPages.new(
        params.merge(autocomplete: request.xhr?)
      )

      @search = Admin::SearchViewModel.new(search, view_model_options)
    end

    def show
      @page = Admin::PageViewModel.new(@page)
    end

    def edit
      @page = Admin::PageViewModel.new(@page)
    end

    def update
      if @page.update_attributes(params[:page])
        flash[:success] = t('workarea.admin.content_pages.flash_messages.saved')
        redirect_to content_page_path(@page)
      else
        @page = Admin::PageViewModel.new(@page)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @page.destroy
      flash[:success] = t('workarea.admin.content_pages.flash_messages.removed')
      redirect_to content_pages_path
    end

    private

    def find_page
      @page = if params[:id].present?
                Content::Page.find_by(slug: params[:id])
              else
                Content::Page.new(params[:page])
              end
    end

    def find_content
      unless @page.new_record?
        model = Content.for(@page)
        @content = Admin::ContentViewModel.new(model, view_model_options)
      end
    end
  end
end
