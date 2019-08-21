require 'test_helper'

module Workarea
  module Admin
    class CommentableViewModelTest < TestCase
      class FooViewModel < ApplicationViewModel
        include CommentableViewModel
      end

      def page
        @page ||= create_page
      end

      def test_has_comments?
        view_model = FooViewModel.new(page)
        refute(view_model.has_comments?)

        create_comment(commentable: page)
        view_model = FooViewModel.new(page)
        assert(view_model.has_comments?)
      end

      def test_new_comments_for?
        user = create_user(admin: true)
        comment = create_comment(commentable: page)

        view_model = FooViewModel.new(page)
        assert(view_model.new_comments_for?(user))

        comment_two = create_comment(commentable: page)
        comment.update(viewed_by_ids: [user.id])

        view_model = FooViewModel.new(page)
        assert(view_model.new_comments_for?(user))

        comment_two.update(viewed_by_ids: [user.id])

        view_model = FooViewModel.new(page)
        refute(view_model.new_comments_for?(user))
      end

      def test_comment_count
        view_model = FooViewModel.new(page)
        assert_equal(0, view_model.comment_count)

        Array.new(3) { create_comment(commentable: page) }
        view_model = FooViewModel.new(page)
        assert_equal(3, view_model.comment_count)
      end
    end
  end
end
