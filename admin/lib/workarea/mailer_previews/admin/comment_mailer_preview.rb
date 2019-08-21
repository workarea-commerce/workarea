module Workarea
  module Admin
    class CommentMailerPreview < ActionMailer::Preview

      def comment_notification
        comment = Comment.first || Order.first.comments.create(body: 'test order comment')
        id = User.first.id
        CommentMailer.notify(id.to_s, comment.id.to_s)
      end
    end
  end
end
