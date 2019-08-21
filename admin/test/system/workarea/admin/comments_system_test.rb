require 'test_helper'

module Workarea
  module Admin
    class CommentsSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_allows_commenting
        user = create_user(email: 'bcrouse-test@workarea.com')
        visit admin.user_path(user)

        click_link 'Comments'

        fill_in 'comment[body]', with: 'test comment'
        click_button 'create_comment'

        assert(page.has_content?('Success'))
      end
    end
  end
end
