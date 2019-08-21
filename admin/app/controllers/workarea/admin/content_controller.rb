module Workarea
  class Admin::ContentController < Admin::ApplicationController
    required_permissions :store

    before_action :check_publishing_authorization
    before_action :find_content, except: :index
    after_action :track_index_filters, only: :index

    def index
      @content = Admin::ContentViewModel.wrap(
        Workarea::Content.system,
        view_model_options
      )
    end

    def show
      unless @content.system?
        redirect_to edit_content_path(@content)
      end

      @content = Admin::ContentViewModel.new(@content, view_model_options)
    end

    def edit
      @content = Admin::ContentViewModel.new(@content, view_model_options)
    end

    def preview
      @content = Admin::ContentViewModel.new(@content, view_model_options)
    end

    def advanced
      @content = Admin::ContentViewModel.wrap(@content, view_model_options)
    end

    def update
      @content.attributes = params[:content]

      if @content.save
        flash[:success] = t('workarea.admin.create_content_pages.flash_messages.saved')
        redirect_to return_to || edit_content_path(@content)
      else
        @content = Admin::ContentViewModel.new(@content)
        render :advanced, status: :unprocessable_entity
      end
    end

    private

    def find_content
      @content = Content.find(params[:id])
    end
  end
end
