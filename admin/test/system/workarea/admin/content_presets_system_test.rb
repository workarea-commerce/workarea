require 'test_helper'

module Workarea
  module Admin
    class ContentPresetsSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_using_a_preset
        Content::Preset.create!(
          name: 'Test Preset',
          type_id: 'html',
          data: { 'html' => '<h1>Test Preset Content</h1>' }
        )

        content = create_content(contentable: create_page)
        visit admin.edit_content_path(content)

        click_link 'add_new_block'
        click_link 'Test Preset'

        assert_current_path(/#{admin.edit_content_path(content)}/)
        assert_equal('<h1>Test Preset Content</h1>', find_field('block[data][html]').value)

        fill_in 'block[data][html]', with: '<h1>Updated Content</h1>'
        click_button 'create_block'

        assert(page.has_content?('Success'))
      end

      def test_managing_presets
        content = create_content(contentable: create_page)
        content_2 = create_content(contentable: create_page)

        visit admin.edit_content_path(content)
        click_link 'add_new_block'
        click_link 'HTML'
        fill_in 'block[data][html]', with: '<h1>Test Content</h1>'
        click_button 'create_block'

        assert(page.has_content?('Success'))
        assert(page.has_selector?('.content-block'))

        find('.content-block').hover
        within('.content-block') do
          click_link 'Create Preset'
        end

        fill_in 'content_preset[name]', with: 'Preset Test'
        click_button 'save_content_preset'

        visit admin.edit_content_path(content_2)
        click_link 'add_new_block'

        wait_for_xhr
        assert(page.has_content?('Preset Test'))
        click_link 'Delete'

        visit admin.edit_content_path(content_2)
        click_link 'add_new_block'

        assert(page.has_no_content?('Presets'))
      end
    end
  end
end
