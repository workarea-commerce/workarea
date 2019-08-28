module Workarea
  module Admin
    class CommentMailer < Admin::ApplicationMailer
      def notify(user_id, comment_id)
        @user = User.find(user_id) rescue nil
        return false unless @user&.email.present?

        model = Comment.where(id: comment_id).first
        return false unless model.present?

        return false if model.author_id == user_id

        @comment = CommentViewModel.new(model)
        @commentable = model.commentable
        @comments = CommentViewModel.wrap(
          @commentable.comments.except(comment_id).to_a
        )

        set_colors

        mail(
          to: @user.email,
          from: Workarea.config.email_from,
          subject: t(
            'workarea.admin.comment_mailer.notify.subject',
            commentable: @commentable.name
          )
        )
      end
    end
  end
end
