require 'test_helper'

module Workarea
  module Admin
    class SearchSettingsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_can_create_an_asset
        patch admin.search_settings_path,
          params: {
            synonyms: 'foo, bar',
            boosts: { 'name' => 3, 'description' => 0.5 },
            views_factor: 1.25,
            terms_facets_list: 'color, size',
            range_facets: {
              'price' => [
                { 'from' => '', 'to' => '9.99' },
                { 'from' => '10', 'to' => '19.99' }
              ]
            }
          }

        settings = Search::Settings.current

        assert_equal('foo, bar', settings.synonyms)
        assert_equal('3', settings.boosts['name'])
        assert_equal('0.5', settings.boosts['description'])
        assert_equal(1.25, settings.views_factor)
        assert_equal(%w(color size), settings.terms_facets)
        assert_equal(
          { 'price' => [{ 'to' => 9.99 }, { 'from' => 10.0, 'to' => 19.99 }] },
          settings.range_facets
        )
      end

      def test_retains_settings_when_partially_updated
        settings = Search::Settings.current
        terms_facets = %w[color size material]
        range_facets = {
          'price' => [
            { 'from' => '', 'to' => '9.99' },
            { 'from' => '10', 'to' => '' }
          ]
        }

        settings.update!(
          terms_facets: terms_facets,
          range_facets: range_facets
        )
        patch admin.search_settings_path,
          params: {
            settings: {
              synonyms: 'foo, bar, baz'
            }
          }

        assert_equal('foo, bar, baz', settings.reload.synonyms)
        assert_equal(terms_facets, settings.terms_facets)
        assert_equal(range_facets, settings.range_facets)
      end
    end
  end
end
