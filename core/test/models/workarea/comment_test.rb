require 'test_helper'

module Workarea
  class CommentTest < TestCase
    def test_default_scope
      commentable = create_page

      comment_2 = create_comment(commentable: commentable, created_at: 2.days.ago)
      comment_3 = create_comment(commentable: commentable, created_at: 3.days.ago)
      comment_1 = create_comment(commentable: commentable, created_at: 1.day.ago)

      assert_equal([comment_3, comment_2, comment_1], Comment.all.to_a)
    end
  end
end
