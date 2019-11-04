module Workarea
  module Admin
    class CommentsController < Admin::ApplicationController
      skip_around_action :set_release
      skip_before_action :mark_release_session
      before_action :find_commentable
      before_action :find_comments
      before_action :find_comment
      before_action :validate_author, only: [:edit, :update, :destroy]
      before_action :mark_comments_as_viewed, only: :index

      def index; end

      def show; end

      def create
        if params[:subscribed_user_ids].present?
          @commentable.add_subscription(params[:subscribed_user_ids])
          @commentable.add_subscription(current_user.id)
        end

        if @comment.save
          flash[:success] = t('workarea.admin.comments.flash_messages.added')
          send_notifications
          redirect_to commentable_comments_path(@commentable.to_global_id)
        else
          @commentable.remove_subscription(params[:subscribed_user_ids])
          flash[:error] = t('workarea.admin.comments.flash_messages.added_error')
          render :index, status: :unprocessable_entity
        end
      end

      def edit; end

      def update
        if @comment.update_attributes(comment_params)
          flash[:success] = t('workarea.admin.comments.flash_messages.saved')
          redirect_to commentable_comments_path(@commentable.to_global_id)
        else
          flash[:error] = t('workarea.admin.comments.flash_messages.saved_error')
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @comment.destroy
        flash[:success] = t('workarea.admin.comments.flash_messages.removed')
        redirect_to commentable_comments_path(@commentable.to_global_id)
      end

      def subscribe
        @commentable.add_subscription(current_user.id)
        flash[:success] = t(
          'workarea.admin.comments.flash_messages.comment_subscribed',
          commentable: @commentable.name
        )
        redirect_to commentable_comments_path(@commentable.to_global_id)
      end

      def unsubscribe
        @commentable.remove_subscription(current_user.id)
        flash[:success] = t(
          'workarea.admin.comments.flash_messages.comment_unsubscribed',
          commentable: @commentable.name
        )
        redirect_to commentable_comments_path(@commentable.to_global_id)
      end

      private

      def find_commentable
        commentable = GlobalID::Locator.locate(params[:commentable_id])
        @commentable = wrap_in_view_model(commentable, view_model_options)
      end

      def find_comments
        @comments = Admin::CommentViewModel.wrap(@commentable.comments)
      end

      def find_comment
        @comment = if params[:id].present?
                     Comment.find(params[:id])
                   else
                     @commentable.model.comments.build(comment_params)
                   end
      end

      def comment_params
        (params[:comment] || {})
          .merge(author_id: current_user.id)
      end

      def validate_author
        if current_user.id.to_s != @comment.author_id
          flash[:error] = t('workarea.admin.comments.flash_messages.comment_edit_error')
          redirect_to commentable_comments_path(@commentable.to_global_id)
          false
        end
      end

      def send_notifications
        @commentable.subscribed_user_ids.each do |id|
          Admin::CommentMailer.notify(id.to_s, @comment.id.to_s).deliver_later
        end
      end

      def mark_comments_as_viewed
        Comment.any_in(commentable_id: @commentable.id)
               .add_to_set(viewed_by_ids: current_user.id)
      end
    end
  end
end
