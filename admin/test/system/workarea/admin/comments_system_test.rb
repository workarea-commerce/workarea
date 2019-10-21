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

      def test_notifying_admins
        me = create_user(email: 'foo@workarea.com')

        create_user(
          first_name: 'Bar',
          last_name: 'Baby',
          email: 'bar@workarea.com'
        )

        create_user(
          first_name: 'Baz',
          last_name: 'Bat',
          email: 'baz@workarea.com',
          admin: true
        )

        visit admin.user_path(me)

        click_link 'Comments'

        find_field('comment[body]').send_keys(['@'])

        refute(page.has_content?('Bar Baby'))
        assert(page.has_content?('Baz Bat'))

        find('.tribute-container li', text: 'Baz Bat (baz@workarea.com)').click
        click_button 'create_comment'

        assert(page.has_content?('Success'))
        assert(page.has_content?('baz@workarea.com'))
      end
    end
  end
end
