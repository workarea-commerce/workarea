module Workarea
  module Storefront
    class DeletionMailer < Storefront::ApplicationMailer
      def confirmation(request_id)
        @deletion_request = Email::DeletionRequest.find(request_id)

        mail(
          to: @deletion_request.email,
          subject: t('workarea.storefront.email.deletion_confirmation.subject')
        )
      end

      def complete(email)
        mail(
          to: email,
          subject: t('workarea.storefront.email.deletion_complete.subject')
        )
      end
    end
  end
end
