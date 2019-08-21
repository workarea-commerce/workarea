require 'test_helper'

module Workarea
  module Admin
    class SearchCustomizationsSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_administrating_search_results_customization
        visit admin.search_customizations_path

        click_button 'add_search_customization'
        within '.tooltip-content' do
          fill_in 'q', with: 'test'
          click_button 'find_search_customization'
        end

        assert(page.has_content?('Success'))

        click_link 'Attributes'
        fill_in 'customization[rewrite]', with: 'rewrite'
        click_button 'save_customization'
        assert(page.has_content?('Success'))

        click_link 'Delete'
        assert(page.has_content?('Success'))
      end

      def test_insights
        search = create_search_customization(id: 'foo')

        Metrics::SearchByDay.inc(
          key: { query_id: 'foo' },
          at: Time.zone.local(2018, 10, 27),
          searches: 333,
          orders: 444,
          units_sold: 555,
          revenue: 666.to_m
        )

        travel_to Time.zone.local(2018, 10, 30)

        visit admin.search_customization_path(search)
        assert(page.has_content?('333'))
        assert(page.has_content?('444'))
        assert(page.has_content?('555'))

        click_link t('workarea.admin.search_customizations.cards.insights.title')
        assert(page.has_content?('333'))
        assert(page.has_content?('444'))
        assert(page.has_content?('555'))
      end

      def test_product_rules
        create_product(name: 'Foo Bar')
        create_product(name: 'Foo Baz')

        visit admin.search_customizations_path

        click_button 'add_search_customization'
        within '.tooltip-content' do
          fill_in 'q', with: 'foo'
          click_button 'find_search_customization'
        end

        assert(page.has_content?('Success'))

        click_link t('workarea.admin.product_rules.card.header')
        assert(
          page.has_content?(
            t('workarea.admin.product_rules.index.base_query_rule', query: 'foo')
          )
        )

        select t('workarea.admin.fields.search').downcase, from: 'product_rule[name]'
        click_button t('workarea.admin.product_rules.index.add_rule')

        fill_in 'product_rule[value]', with: 'bar'
        assert(page.has_no_content?('Foo Baz'))
        assert(page.has_content?('Foo Bar'))

        click_button t('workarea.admin.actions.save')

        assert(page.has_content?('Success'))
        assert(page.has_content?('Foo Bar'))
        assert(page.has_no_content?('Foo Baz'))

        click_link t('workarea.admin.actions.remove')
        assert(page.has_content?('Success'))
        assert(page.has_content?('Foo Bar'))
        assert(page.has_content?('Foo Baz'))
      end

      def test_analysis
        visit admin.search_customizations_path

        click_button 'add_search_customization'
        within '.tooltip-content' do
          fill_in 'q', with: 'test'
          click_button 'find_search_customization'
        end

        click_link t('workarea.admin.search_customizations.cards.analyze.title')
        assert(page.has_content?(t('workarea.admin.search_customizations.analyze.title')))
        assert(page.has_content?(t('workarea.admin.search_customizations.analyze.no_results')))
      end

      def test_searches_in_primary_nav
        Workarea::Insights::PopularSearches.create!(results: [
          { query_string: 'foo search' },
          { query_string: 'bar search' },
        ])

        visit admin.root_path

        click_link 'open_primary_nav'

        within '#takeover' do
          assert(page.has_content?('foo search'))
          assert(page.has_content?('bar search'))
          click_link 'bar search'
        end

        assert(page.has_content?('bar search'))

        click_link "↑ #{t('workarea.admin.search_customizations.show.index_link')}"

        assert(page.has_content?(t('workarea.admin.search_customizations.index.popular_searches')))
        assert(page.has_content?('foo search'))
        assert(page.has_content?('bar search'))
      end
    end
  end
end
