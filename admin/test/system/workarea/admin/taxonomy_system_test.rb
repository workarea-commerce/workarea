require 'test_helper'

module Workarea
  module Admin
    class TaxonomySystemTest < SystemTest
      include Admin::IntegrationTest

      def test_management
        visit admin.navigation_taxons_path
        page.find('.menu-editor__add-item-button--last-position').click

        fill_in 'taxon[name]', with: 'First Taxon'
        fill_in 'taxon[url]', with: '/test'
        click_button 'create_taxon'

        assert(page.has_content?('Success'))
        assert(page.has_content?('First Taxon'))


        click_link 'First Taxon'
        wait_for_xhr
        within '.menu-editor__menu:last-child' do
          page.find('.menu-editor__add-item-button--last-position').click
        end

        fill_in 'taxon[name]', with: 'Second Taxon'
        fill_in 'taxon[url]', with: '/test'
        click_button 'create_taxon'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Second Taxon'))

        click_button 'remove_taxon', match: :first

        assert(page.has_content?('Success'))
        refute_text('First Taxon')
        refute_text('Second Taxon')
      end
    end
  end
end
