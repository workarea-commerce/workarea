require 'test_helper'

module Workarea
  module Storefront
    class PrivacyPopupSystemTest < Workarea::SystemTest
      def test_privacy_popup
        layout = Content.for('layout')
        layout.blocks.create!(
          area: 'privacy_popup',
          type: 'html',
          data: { html: '<p>Foo Bar</a>' }
        )

        Workarea.config.show_privacy_popup = false
        visit storefront.root_path
        assert_no_selector('.ui-dialog')
        assert_page_reloaded do
          find('a[rel="home"]').click
        end

        Workarea.config.show_privacy_popup = true
        visit storefront.root_path
        assert_selector('.ui-dialog')
        assert_raises Selenium::WebDriver::Error::ElementClickInterceptedError do
          find('a[rel="home"]').click
        end

        within('.ui-dialog') { click_button t('workarea.storefront.users.agree') }
        assert_no_selector('.ui-dialog')

        assert_page_reloaded do
          find('a[rel="home"]').click
        end
      end

      private

      def assert_page_reloaded
        page.execute_script("$('body').addClass('not-reloaded')")
        yield
        refute(page.has_selector?('body.not-reloaded'), 'Page should have reloaded')
      end
    end
  end
end
