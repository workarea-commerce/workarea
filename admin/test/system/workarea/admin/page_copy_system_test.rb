require 'test_helper'

module Workarea
  module Admin
    class PageCopySystemTest < Workarea::SystemTest
      include Admin::IntegrationTest

      def test_copy_from_page_show
        content_page = create_page
        content = Content.for(content_page)
        content.blocks.build(
          type_id: :html,
          data: { html: '<p>Test!</p>' }
        )
        content.save!

        visit admin.content_page_path(content_page)
        click_link t('workarea.admin.content_pages.show.copy_page')

        fill_in 'page[id]', with: 'FOOBAR'

        click_button 'create_copy'
        assert(page.has_content?('Success'))
        assert_current_path(
          admin.edit_create_content_page_path(
            "#{content_page.slug}-1",
            continue: true
          )
        )

        click_button 'save_setup'
        within '.content-editor__aside' do
          assert(page.has_content?('HTML'))
        end
      end

      def test_copy_from_create_workflow
        create_page(name: 'Original Page')

        visit admin.create_content_pages_path
        click_link t('workarea.admin.create_content_pages.setup.copy_button')

        find('.select2-selection--single').click
        find('.select2-results__option', text: 'Original Page').click

        fill_in 'page[id]', with: 'FOOBAR'

        click_button 'create_copy'
        assert(page.has_content?('Success'))
        assert_current_path(
          admin.edit_create_content_page_path(
            'original-page-1',
            continue: true
          )
        )
      end
    end
  end
end
