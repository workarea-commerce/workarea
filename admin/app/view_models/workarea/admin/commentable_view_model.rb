module Workarea
  module Admin
    module CommentableViewModel
      def has_comments?
        comment_count > 0
      end

      def new_comments_for?(user)
        comments.any? { |c| !user.id.in?(c.viewed_by_ids) }
      end

      def comment_count
        @comment_count ||= comments.count
      end

      def comments
        @comments ||= CommentViewModel.wrap(model.comments)
      end

      def subscribed_users
        @users ||= User.in(id: subscribed_user_ids)
      end
    end
  end
end
