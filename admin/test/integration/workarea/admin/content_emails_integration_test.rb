require 'test_helper'

module Workarea
  module Admin
    class ContentEmailsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest
      setup :set_email

      def set_email
        @email = Workarea::Content::Email.create!(type: 'test', content: 'Foo')
      end

      def test_can_update_a_content_email
        patch admin.content_email_path(@email.id),
          params: { email: { content: 'Updated message!' } }

        email = Content::Email.first
        assert_equal('Updated message!', email.content)
      end
    end
  end
end
