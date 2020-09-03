require 'test_helper'

module Workarea
  module Admin
    class ContentSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_managing_content_blocks
        home = create_content(name: 'home_page')
        visit admin.content_index_path
        click_link 'Home Page'
        within '.card--content' do
          click_link 'Content'
        end

        assert(page.has_content?('Home Page'))

        click_link 'add_new_block'
        click_link 'HTML'
        assert_current_path(/#{admin.edit_content_path(home)}/)
        fill_in 'block[data][html]', with: '<h1>Some Content!</h1>'
        click_button 'create_block'

        assert(page.has_content?('Success'))
        assert_current_path(/#{admin.edit_content_path(home)}/)
        assert(page.has_selector?('.content-block'))

        within '.content-editor__aside' do
          assert(page.has_content?('HTML'))
        end

        find('.content-block').click
        click_link t('workarea.admin.content.form.edit_block_name')
        fill_in 'block[name]', with: 'Foo Bar Block'
        fill_in 'block[data][html]', with: '<h1>Some Content!</h1>'
        click_button 'save_block'

        assert(page.has_content?('Success'))
        assert_current_path(/#{admin.edit_content_path(home)}/)
        assert(page.has_selector?('.content-block'))

        within '.content-editor__aside' do
          assert(page.has_content?('Foo Bar Block'))
        end

        find('.content-block').click
        click_link t('workarea.admin.actions.delete')
        refute(page.has_selector?('.content-block'))
      end

      def test_copying_content_blocks
        home = create_content(name: 'home_page')
        visit admin.content_index_path
        click_link 'Home Page'
        within '.card--content' do
          click_link 'Content'
        end

        click_link 'add_new_block'
        click_link 'HTML'

        fill_in 'block[data][html]', with: '<h1>Some Content!</h1>'
        click_button 'create_block'

        assert(page.has_content?('Success'))

        find('.content-block').hover
        find('.content-block__action-button--copy').click

        assert(page.has_content?('Success'))
        assert(page.has_content?(t('workarea.admin.content_blocks.flash_messages.copied')))

        assert_selector('.content-block', count: 2)

        find_all('.content-block').last.click
        assert_equal(
          '<h1>Some Content!</h1>',
          find('[name="block[data][html]"]').value
        )

        fill_in 'block[data][html]', with: '<h1>Foo Blargh!</h1>'
        click_button 'save_block'

        assert(page.has_content?('Success'))

        find_all('.content-block').first.click
        assert_equal(
          '<h1>Some Content!</h1>',
          find('[name="block[data][html]"]').value
        )

        find_all('.content-block').last.click
        assert_equal(
          '<h1>Foo Blargh!</h1>',
          find('[name="block[data][html]"]').value
        )
      end

      def test_reordering_content_blocks
        home = create_content(name: 'home_page')
        visit admin.content_index_path
        click_link 'Home Page'
        within '.card--content' do
          click_link 'Content'
        end

        click_link 'add_new_block'
        click_link 'HTML'

        fill_in 'block[data][html]', with: '<h1>Some Content!</h1>'
        click_button 'create_block'
        assert(page.has_content?('Success'))

        find('.content-block').hover
        find('.content-block__add-button--bottom').click

        click_link 'Recommendations'
        click_button 'create_block'
        assert(page.has_content?('Success'))

        assert(page.has_selector?('.ui-sortable'))
      end

      def test_managing_content_blocks_for_a_release
        home = create_content(name: 'home_page', blocks: [])
        release = create_release(name: 'Foo')

        visit admin.content_path(home)
        select 'Foo', from: 'release_id'

        # assert pauses for submission debounce when switching releases
        assert_equal(release.id.to_s, find_field('release_id').value)

        within '.card--content' do
          click_link 'Content'
        end

        click_link 'add_new_block'
        click_link 'HTML'
        assert_current_path(/#{admin.edit_content_path(home)}/)
        fill_in 'block[data][html]', with: '<h1>Some Content!</h1>'
        click_button 'create_block'

        assert_current_path(/#{admin.edit_content_path(home)}/)
        assert(page.has_content?('Success'))
        assert(page.has_selector?('.content-block'))
      end

      def test_editing_advanced_content_fields
        home = create_content(name: 'home_page')
        visit admin.edit_content_path(home)
        click_link 'Advanced', match: :first

        assert_current_path(/#{admin.advanced_content_path(home)}/)

        assert(page.has_selector?('#content_browser_title', visible: false))

        find('.toggle-button__label--positive').click
        assert(page.has_selector?('#content_browser_title', visible: true))

        fill_in 'content[browser_title]', with: 'Browser Title'
        fill_in 'content[content_security_policy]', with: %(default-src 'self')
        click_button 'save'

        assert(page.has_content?('Success'))
        assert_current_path(/#{admin.edit_content_path(home)}/)

        home.reload
        assert_equal('Browser Title', home.browser_title)
        assert_equal(%(default-src 'self'), home.content_security_policy)
      end

      def test_content_previewing
        home = create_content(name: 'home_page')
        visit admin.content_index_path
        click_link 'Home Page'
        within '.card--content' do
          click_link 'Content'
        end

        assert(page.has_content?('Home Page'))

        click_link 'add_new_block'
        click_link 'HTML'
        assert_current_path(/#{admin.edit_content_path(home)}/)
        fill_in 'block[data][html]', with: '<h1>Some Content!</h1>'
        click_button 'create_block'

        assert(page.has_content?('Success'))
        click_link 'Preview'
        assert(page.has_content?('This is an approximation of how your site will appear on different devices.'))

        within_frame find('.content-preview__iframe') do
          assert_text('Some Content!')
        end
      end
    end
  end
end
