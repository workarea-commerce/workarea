require 'test_helper'

module Workarea
  module Admin
    class CommentMailerTest < MailerTest
      include TestCase::SearchIndexing
      include TestCase::Mail

      delegate :t, to: :I18n

      def test_notify
        Workarea.config.email_from = 'noreply@example.com'
        user = create_user
        product = create_product
        comment = product.comments.create!(body: 'test order comment')

        CommentMailer.notify(user.id, comment.id).deliver_now

        email = ActionMailer::Base.deliveries.last
        html = email.parts.second.body

        assert_includes(email.to, user.email)
        assert_includes(email.from, Workarea.config.email_from)
        assert_includes(html, comment.body)
        assert_includes(
          html,
          t(
            'workarea.admin.comment_mailer.notify.unsubscribe_from_notifications',
            commentable_name: product.name
          )
        )
      end
    end
  end
end
