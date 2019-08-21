module Workarea
  module Storefront
    class InquiryMailer < Storefront::ApplicationMailer
      def created(id)
        @inquiry = Inquiry.find(id)
        mail(to: Workarea.config.email_to, subject: @inquiry.full_subject)
      end
    end
  end
end
