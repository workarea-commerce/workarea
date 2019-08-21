require 'test_helper'

module Workarea
  module Admin
    class RedirectsSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_managing_redirects
        visit admin.navigation_redirects_path

        click_button t('workarea.admin.navigation_redirects.index.add_new')
        fill_in 'redirect[path]', with: '/test'
        fill_in 'redirect[destination]', with: 'http://www.google.com'
        click_button 'save_redirect'

        assert(page.has_content?('/test'))

        click_link t('workarea.admin.actions.delete')
        assert(page.has_no_content?('/test'))
      end

      def test_filtering_redirects
        create_redirect(path: "/original-foo", destination: '/new-bar')
        create_redirect(path: "/foo", destination: '/new-baz')

        visit admin.navigation_redirects_path

        fill_in 'search_redirects', with: 'foo'
        find('#search_redirects').native.send_keys(:return)

        assert(page.has_content?('/foo'))
        assert(page.has_no_content?('/original-foo'))

        fill_in 'search_redirects', with: 'new'
        find('#search_redirects').native.send_keys(:return)

        assert(page.has_content?('/foo'))
        assert(page.has_content?('/original-foo'))
      end
    end
  end
end
