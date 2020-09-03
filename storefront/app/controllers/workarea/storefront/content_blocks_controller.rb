module Workarea
  class Storefront::ContentBlocksController < Storefront::ApplicationController
    layout 'workarea/storefront/empty'

    skip_around_action :apply_segments
    before_action :require_login
    before_action :require_admin
    before_action :disable_xss_protection
    skip_after_action :set_content_security_policy

    def new
      @content = Content.find(params[:content_id])
      block = @content.blocks.build(type_id: params[:type_id])
      block.data = block.type.defaults
      @block = Storefront::ContentBlockViewModel.wrap(block, view_model_options)

      render :show
    end

    def show
      @content = Content.from_block(params[:id])
      block = @content.blocks.find(params[:id])

      @block = Storefront::ContentBlockViewModel.wrap(block, view_model_options)
    end

    def draft
      draft = Content::BlockDraft.find(params[:id])

      @content = draft.content
      @block = Storefront::ContentBlockViewModel.wrap(
        draft.to_block,
        view_model_options
      )

      render :show
    end

    private

    def require_admin
      unless current_admin.present?
        flash[:error] = 'You are not authorized to perform this action'
        redirect_to auth_failure_destination
        return false
      end
    end

    def disable_xss_protection
      response.headers['X-XSS-Protection'] = '0'
    end
  end
end
