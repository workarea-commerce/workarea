require 'test_helper'

module Workarea
  module Storefront
    class SegmentOverridesSystemTest < Workarea::SystemTest
      def test_previewing_a_segment
        set_current_user(create_user(super_admin: true))
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

        visit storefront.root_path
        within_frame find('.admin-toolbar') do
          wait_for_iframe
          click_link 'select_segments'
        end

        assert_content(t('workarea.admin.segment_overrides.show.title'))
        find("#segment_ids_#{segment_one.id}_#{segment_one.id}_true_label").click
        click_button 'set_overrides'

        assert_current_path(storefront.root_path)
        assert_content('Foo')
        assert_no_content('Bar')
        within_frame find('.admin-toolbar') do
          wait_for_iframe
          assert_content('Test One')
          click_link 'select_segments'
        end

        assert_content(t('workarea.admin.segment_overrides.show.title'))
        find("#segment_ids_#{segment_one.id}_#{segment_one.id}_false_label").click
        find("#segment_ids_#{segment_two.id}_#{segment_two.id}_true_label").click
        click_button 'set_overrides'

        assert_current_path(storefront.root_path)
        assert_no_content('Foo')
        assert_content('Bar')
        within_frame find('.admin-toolbar') do
          wait_for_iframe
          refute_content('Test One')
          assert_content('Test Two')
        end
      end
    end
  end
end
