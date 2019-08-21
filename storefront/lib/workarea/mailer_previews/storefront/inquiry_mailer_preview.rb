module Workarea
  module Storefront
    class InquiryMailerPreview < ActionMailer::Preview
      def created
        InquiryMailer.created(Inquiry.first.id)
      end
    end
  end
end
