require 'test_helper'

module Workarea
  module Admin
    class UnsubscribesIntegrationTest < Workarea::IntegrationTest
      def test_unsubscribing_from_status_report
        user = create_user(status_email_recipient: true)

        get admin.status_report_unsubscribe_path(user.token)

        assert_redirected_to(storefront.root_path)
        assert(flash[:success].present?)

        user.reload
        refute(user.status_email_recipient)
      end

      def test_unsubscribing_from_commentable
        user = create_user(admin: true)
        commentable = create_release(subscribed_user_ids: [user.id])

        get admin.commentable_unsubscribe_url(
          user.token,
          commentable_id: commentable.to_global_id
        )

        commentable.reload
        assert_equal([], commentable.subscribed_user_ids)
      end
    end
  end
end
