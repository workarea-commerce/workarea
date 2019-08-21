module Workarea
  module Admin
    class HelpController < Admin::ApplicationController
      include HelpAuthorization

      before_action :find_help_article, except: :index
      before_action :find_help_assets, except: :index
      skip_before_action :check_help_authorization, only: [:index, :show]

      # TODO remove related help in v4
      def index
        related_help = params[:like_text].present? || params[:for_url].present?

        if request.xhr? && related_help
          search = Search::RelatedHelp.new(params)
          @search = Admin::HelpSearchViewModel.new(search, view_model_options)
          render :takeover
        else
          search = Search::HelpSearch.new(params)
          @search = Admin::HelpSearchViewModel.new(search, view_model_options)
        end
      end

      def show
        search = Search::RelatedHelp.new(ids: [@help_article.id])
        @related = Admin::HelpSearchViewModel.new(search, view_model_options)
        @article_body = Redcarpet::Markdown.new(
          Redcarpet::Render::HTML.new(hard_wrap: true)
        ).render(@help_article.body.html_safe)
      end

      def new
      end

      def create
        if @help_article.save
          flash[:success] = t('workarea.admin.help.flash_messages.created')
          redirect_to help_index_path
        else
          flash[:error] = t('workarea.admin.help.flash_messages.save_error')
          render :new
        end
      end

      def edit
      end

      def update
        if @help_article.update_attributes(params[:help_article])
          flash[:success] = t('workarea.admin.help.flash_messages.updated')
          redirect_to help_path(@help_article)
        else
          flash[:error] = t('workarea.admin.help.flash_messages.save_error')
          render :edit
        end
      end

      def destroy
        @help_article.destroy
        flash[:success] = t('workarea.admin.help.flash_messages.removed')
        redirect_to help_index_path
      end

      private

      def find_help_article
        @help_article = if params[:id].present?
                     Help::Article.find(params[:id])
                   else
                     Help::Article.new(params[:help_article])
                   end
      end

      def find_help_assets
        @help_assets = Help::Asset.all.desc(:created_at)
      end
    end
  end
end
