require 'test_helper'

module Workarea
  module Storefront
    class PrivacySystemTest < Workarea::SystemTest
      def test_submitting_deletion_request
        visit storefront.root_path

        click_link t('workarea.storefront.privacy.link')

        within '#deletion_request_form' do
          fill_in :email, with: 'test@workarea.com'
          click_button 'submit'
        end

        assert_current_path(storefront.privacy_path)
        assert(page.has_content?('Success'))
      end
    end
  end
end
