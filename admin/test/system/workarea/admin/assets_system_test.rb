require 'test_helper'

module Workarea
  module Admin
    class AssetsSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_management
        visit admin.content_assets_path
        click_link 'add_asset'

        fill_in 'asset[name]', with: 'Test Asset'
        attach_file 'asset[file]', product_image_file_path
        click_button 'create_asset'
        assert(page.has_content?('Success'))
        assert(page.has_content?('Test Asset'))

        click_link 'Attributes'
        fill_in 'asset[name]', with: 'Edited Asset'
        click_button 'save_asset'
        assert(page.has_content?('Success'))
        assert(page.has_content?('Edited Asset'))

        click_link '↑ All assets'
        click_link 'Edited Asset'
        click_link 'Delete'

        assert_current_path(admin.content_assets_path)
        assert(page.has_content?('Success'))
        refute_text('Edited Asset')
      end

      def test_insertion
        asset = create_asset

        content = create_content(
          contentable: create_page,
          blocks: [
            { type: 'hero', data: { asset: asset.id } }
          ]
        )

        visit admin.edit_content_path(content)
        find('.content-block').click

        find('.asset-picker-field a').click
        within '#takeover' do
          click_link 'Test Asset'
        end

        within '.asset-picker-field' do
          assert(page.has_content?('Test Asset'))
        end
      end

      def test_clearing
        asset = create_asset

        content = create_content(
          contentable: create_page,
          blocks: [
            { type: 'hero', data: { asset: asset.id } }
          ]
        )

        visit admin.edit_content_path(content)
        find('.content-block').click
        assert(page.has_content?('Test Asset'))

        click_button 'Clear asset'
        assert(page.has_content?('(none)'))
      end
    end
  end
end
