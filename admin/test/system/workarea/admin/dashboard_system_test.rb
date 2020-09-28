require 'test_helper'

module Workarea
  module Admin
    class DashboardSystemTest < SystemTest
      include Admin::IntegrationTest

      #
      # Smoke tests to ensure dashboard display works
      #

      def test_viewing_the_main_dashboard
        hot = create_hot_products
        cold = create_cold_products

        visit admin.root_path
        assert(page.has_content?(t('workarea.admin.dashboards.index.admin')))
        assert(page.has_content?(hot.results.first['product_id']))
      end

      def test_viewing_the_store_dashboard
        visit admin.store_dashboards_path
        assert(page.has_content?(t('workarea.admin.dashboards.store.title')))
      end

      def test_viewing_search_dashboard
        visit admin.search_dashboards_path
        assert(page.has_content?(t('workarea.admin.dashboards.search.search')))
      end

      def test_viewing_the_catalog_dashboard
        visit admin.catalog_dashboards_path
        assert(page.has_content?(t('workarea.admin.dashboards.catalog.catalog')))
      end

      def test_viewing_the_marketing_dashboard
        visit admin.marketing_dashboards_path
        assert(page.has_content?(t('workarea.admin.dashboards.marketing.marketing')))
      end

      def test_viewing_the_orders_dashboard
        visit admin.orders_dashboards_path
        assert(page.has_content?(t('workarea.admin.dashboards.orders.orders')))
      end

      def test_viewing_the_people_dashboard
        visit admin.people_dashboards_path
        assert(page.has_content?(t('workarea.admin.dashboards.people.people')))
      end

      def test_viewing_the_reports_dashboard
        visit admin.reports_dashboards_path
        assert(page.has_content?(t('workarea.admin.dashboards.reports.title')))
      end

      def test_viewing_the_settings_dashboard
        Workarea.config.fooconfig = 'barvalue'

        visit admin.settings_dashboards_path
        assert(page.has_content?('Fooconfig'))
        assert(page.has_content?('barvalue'))
        assert(page.has_selector?('.jump-to-menu'))

        Workarea.config.hide_from_settings = %i(fooconfig)

        visit admin.settings_dashboards_path
        refute_text('Fooconfig')
      end
    end
  end
end
