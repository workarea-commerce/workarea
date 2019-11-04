require 'test_helper'

module Workarea
  module Admin
    class CommentsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def current_user
        @current_user ||= User.where(super_admin: true).first
      end

      def user_1
        @user_1 ||= create_user(email: 'test1@workarea.com')
      end

      def user_2
        @user_2 ||= create_user(email: 'test2@workarea.com')
      end

      def user_3
        @user_3 ||= create_user(email: 'test3@workarea.com')
      end

      def user_4
        @user_4 ||= create_user(email: 'test4@workarea.com')
      end

      def commentable
        @commentable ||= create_release(
          name: 'Test Release',
          subscribed_user_ids: [current_user.id, user_1.id]
        )
      end

      def test_viewing_comments
        comments = Array.new(3) do
          create_comment(
            commentable: commentable,
            body: 'foo comment',
            author_id: user_2.id
          )
        end

        get admin.commentable_comments_path(commentable.to_global_id)

        assert(response.ok?)
        comments.map do |comment|
          comment.reload
          assert(comment.viewed_by_ids.include?(current_user.id))
        end
      end

      def test_viewing_comments_without_an_author
        create_comment(
          commentable: commentable,
          body: 'system generated comment'
        )

        get admin.commentable_comments_path(commentable.to_global_id)
        assert(response.ok?)
      end

      def test_adding_comment_and_subscribing
        create_comment(commentable: commentable, body: 'comment history')

        post admin.commentable_comments_path(commentable.to_global_id),
          params: {
            subscribed_user_ids: [user_2.id, user_3.id],
            comment: { body: 'some content' }
          }

        assert_equal(2, Comment.count)
        comment = Comment.all.last
        assert_equal('some content', comment.body)

        commentable.reload
        assert_includes(commentable.subscribed_user_ids, current_user.id.to_s)
        assert_includes(commentable.subscribed_user_ids, user_1.id.to_s)
        assert_includes(commentable.subscribed_user_ids, user_2.id.to_s)
        assert_includes(commentable.subscribed_user_ids, user_3.id.to_s)

        # Don't send an email to the author
        all_emails = ActionMailer::Base.deliveries.map(&:to)
        refute_includes(all_emails, current_user.email)

        emails = ActionMailer::Base.deliveries.last(3)
        assert_includes(emails.first.to, user_1.email)
        assert_includes(emails.second.to, user_2.email)
        assert_includes(emails.third.to, user_3.email)

        emails.map(&:parts).flatten.each do |part|
          assert_includes(part.body, 'some content')
          assert_includes(part.body, 'comment history')
        end
      end

      def test_editing_comment_as_author
        comment = create_comment(commentable: commentable, body: 'body')

        patch admin.commentable_comment_path(commentable.to_global_id, comment),
          params: { comment: { body: 'different body' } }

        comment.reload
        assert_equal('body', comment.body)
        comment.update_attributes(author_id: current_user.id)

        patch admin.commentable_comment_path(commentable.to_global_id, comment),
          params: { comment: { body: 'different body' } }

        comment.reload
        assert_equal('different body', comment.body)
      end

      def test_deleting_comment_as_author
        comment = create_comment(commentable: commentable)
        delete admin.commentable_comment_path(commentable.to_global_id, comment)

        assert_equal(1, Comment.count)
        comment.update_attributes(author_id: current_user.id)

        delete admin.commentable_comment_path(commentable.to_global_id, comment)
        assert_equal(0, Comment.count)
      end

      def test_commenting_with_active_release
        product = create_product(name: 'Foo')
        release = create_release
        release.as_current { product.update(name: 'Bar') }


        post admin.release_session_path, params: { release_id: release.id }

        post admin.commentable_comments_path(product.to_global_id),
          params: {
            subscribed_user_ids: [user_2.id],
            comment: { body: 'some content' }
          }

        comment = Comment.all.last
        assert_equal('some content', comment.body)

        product.reload
        assert_includes(product.subscribed_user_ids, current_user.id.to_s)
        assert_includes(product.subscribed_user_ids, user_2.id.to_s)
        assert_equal('Foo', product.name)
        release.as_current { assert_equal('Bar', product.reload.name) }
      end

      def test_subscribing_to_comments
        put admin.subscribe_commentable_comments_path(commentable.to_global_id)

        assert_redirected_to(admin.commentable_comments_path(commentable.to_global_id))
        assert(flash[:success].present?)
        assert_includes(commentable.reload.subscribed_user_ids, current_user.id.to_s)
      end

      def test_unsubscribing_to_comments
        commentable.update!(subscribed_user_ids: [current_user.id])
        put admin.unsubscribe_commentable_comments_path(commentable.to_global_id)

        assert_redirected_to(admin.commentable_comments_path(commentable.to_global_id))
        assert(flash[:success].present?)
        refute_includes(commentable.reload.subscribed_user_ids, current_user.id.to_s)
      end
    end
  end
end
