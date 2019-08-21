module Workarea
  class Admin::ContentPresetsController < Admin::ApplicationController
    required_permissions :store
    before_action :set_content_block, only: :create

    def new
    end

    def create
      @preset = Content::Preset.new(params[:content_preset])
      @preset.apply_block(@block) if @block.present?

      if @preset.save
        flash[:success] = t('workarea.admin.content_presets.flash_messages.saved')

        if request.xhr?
          head :created
        else
          redirect_to return_to || edit_content_path(@content)
        end
      else
        flash[:error] = t('workarea.admin.content_presets.flash_messages.preset_error')
        head :unprocessable_entity
      end
    end

    def destroy
      preset = Content::Preset.find(params[:id])
      preset.destroy
      head :no_content
    end

    private

    def set_content_block
      @content = Content.find(params[:content_id])
      @block = @content.blocks.find(params[:block_id])
    end
  end
end
