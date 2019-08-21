require 'test_helper'

module Workarea
  module Storefront
    class ContactFormIntegrationTest < Workarea::IntegrationTest
      def test_inquiry_creation
        Workarea.config.email_to = 'test@workarea.com'

        post storefront.contact_path,
          params: {
            name: 'Ben Crouse',
            email: 'bcrouse@workarea.com',
            subject: 'orders',
            order_id: 'ORDER123',
            message: 'test message'
          }

        result = Inquiry.first
        assert_equal('Ben Crouse', result.name)
        assert_equal('bcrouse@workarea.com', result.email)
        assert(result.subject.present?)
        assert_equal('ORDER123', result.order_id)
        assert_equal('test message', result.message)

        last_email = ActionMailer::Base.deliveries.last
        assert_includes(last_email.subject, 'Orders')
        assert_includes(last_email.to, Workarea.config.email_to)
      end
    end
  end
end
