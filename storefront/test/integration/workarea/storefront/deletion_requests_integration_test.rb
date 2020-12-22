require 'test_helper'

module Workarea
  module Storefront
    class DeletionRequestIntegrationTest < Workarea::IntegrationTest
      def test_create
        post storefront.deletion_request_path,
          params: { email: 'test@workarea.com' }

        assert_equal(1, Email::DeletionRequest.count)

        deletion = Email::DeletionRequest.first
        assert_equal('test@workarea.com', deletion.email)
        assert(deletion.process_at.present?)

        delivery = ActionMailer::Base.deliveries.last
        assert_includes(delivery.subject, t('workarea.storefront.email.deletion_confirmation.subject'))
        assert_includes(delivery.to, deletion.email)
        assert_includes(delivery.html_part.body, deletion.process_at.to_date.to_s(:date_only))
      end

      def test_cancel
        deletion = Email::DeletionRequest.create!(email: 'test@workarea.com')
        assert_equal(1, Email::DeletionRequest.count)

        get storefront.cancel_deletion_request_path(deletion.token)

        assert_equal(0, Email::DeletionRequest.count)
        assert_redirected_to(storefront.root_path)
      end
    end
  end
end
