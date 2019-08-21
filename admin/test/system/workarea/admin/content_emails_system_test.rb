require 'test_helper'

module Workarea
  module Admin
    class ContentEmailsSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_editing_a_content_email
        Content::Email.create!(type: 'test_type', content: 'Test content')

        visit admin.content_emails_path
        click_link('Test Type')

        page.execute_script('$("body", $("iframe.wysihtml-sandbox").contents()).text("FOO BAR BAZ")')
        within '#content-email_form' do
          click_button 'save_content_email'
        end

        assert_equal(admin.content_emails_path, current_path)
        assert(page.has_content?('Success'))

        click_link('Test Type')

        text = page.evaluate_script('$("body", $("iframe.wysihtml-sandbox").contents()).text()')
        assert_equal('FOO BAR BAZ', text)
      end
    end
  end
end
