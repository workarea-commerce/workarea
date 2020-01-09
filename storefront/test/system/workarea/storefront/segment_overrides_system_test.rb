require 'test_helper'

module Workarea
  module Storefront
    class SegmentOverridesSystemTest < Workarea::SystemTest
      def test_previewing_a_segment
        admin = create_user(super_admin: true)
        segment_one = create_segment(name: 'Test One', rules: [])
        segment_two = create_segment(name: 'Test Two', rules: [])

        content = Content.for('home_page')
        content.blocks.create!(
          type: 'html',
          data: { 'html' => '<p>Foo</p>' },
          active_segment_ids: [segment_one.id]
        )
        content.blocks.create!(
          type: 'html',
          data: { 'html' => '<p>Bar</p>' },
          active_segment_ids: [segment_two.id]
        )

        # Don't use `set_current_user` because we need to test middleware stack
        visit storefront.login_path

        within '#login_form' do
          fill_in 'email', with: admin.email
          fill_in 'password', with: admin.password
          click_button t('workarea.storefront.users.login')
        end

        assert(page.has_content?('Success'))

        visit storefront.root_path
        page.document.synchronize do
          within_frame find('.admin-toolbar') do
            find_link 'select_segments'
            click_link 'select_segments'
          end
        end

        assert_content(t('workarea.admin.segment_overrides.show.title'))
        find("#segment_ids_#{segment_one.id}_#{segment_one.id}_true_label").click
        click_button 'set_overrides'

        assert_current_path(storefront.root_path)
        assert_content('Foo')
        assert_no_content('Bar')
        page.document.synchronize do
          within_frame find('.admin-toolbar') do
            find_link 'select_segments'
            assert_content('Test One')
            click_link 'select_segments'
          end
        end

        assert_content(t('workarea.admin.segment_overrides.show.title'))
        find("#segment_ids_#{segment_one.id}_#{segment_one.id}_false_label").click
        find("#segment_ids_#{segment_two.id}_#{segment_two.id}_true_label").click
        click_button 'set_overrides'

        assert_current_path(storefront.root_path)
        assert_no_content('Foo')
        assert_content('Bar')
        page.document.synchronize do
          within_frame find('.admin-toolbar') do
            find_link 'select_segments'
            refute_content('Test One')
            assert_content('Test Two')
          end
        end
      end
    end
  end
end
