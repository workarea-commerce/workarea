require 'test_helper'

module Workarea
  module Admin
    class SearchSettingsSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_administrating_settings
        visit admin.search_settings_path

        click_link t('workarea.admin.search_settings.show.synonyms.title')
        fill_in 'synonyms', with: 'ben, foo'

        click_link t('workarea.admin.search_settings.show.filters.title')
        fill_in 'terms_facets_list', with: 'color, size, material'

        click_link t('workarea.admin.search_settings.show.boosts.title')
        fill_in 'boosts[name]', with: '3'
        fill_in 'boosts[description]', with: '0.5'
        click_button 'save_settings'

        click_link t('workarea.admin.search_settings.show.synonyms.title')
        assert_equal('ben, foo', find_field('synonyms').value)

        click_link t('workarea.admin.search_settings.show.filters.title')
        assert_equal('color, size, material', find_field('terms_facets_list').value)

        click_link t('workarea.admin.search_settings.show.boosts.title')
        assert_equal('3', find_field('boosts[name]').value)
        assert_equal('0.5', find_field('boosts[description]').value)
      end
    end
  end
end
