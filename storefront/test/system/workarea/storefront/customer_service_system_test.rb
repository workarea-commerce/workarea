require 'test_helper'

module Workarea
  module Storefront
    class CustomerServiceSystemTest < Workarea::SystemTest
      def test_logs_to_the_database_and_sends_an_email
        visit storefront.contact_path

        within '#customer_service_form' do
          fill_in 'name', with: 'Ben Crouse'
          fill_in 'email', with: 'bcrouse@workarea.com'
          fill_in 'order_id', with: 'ORDER123'
          fill_in 'message', with: 'test message'
          click_button t('workarea.storefront.forms.send')
        end

        assert(page.has_content?('Success'))
      end
    end
  end
end
