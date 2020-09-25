require 'test_helper'

module Workarea
  module Storefront
    class SitemapsIntegrationTest < Workarea::IntegrationTest
      setup :create_index
      teardown :reset_index

      def create_index
        @create_index = SitemapGenerator::Sitemap.create_index
      end

      def reset_index
        SitemapGenerator::Sitemap.create_index = @create_index
      end

      def test_returns_200_status_code
        GenerateSitemaps.new.perform
        get '/sitemap.xml.gz'

        assert_equal(200, response.status)
      end

      def test_handles_multiple_sitemaps_via_an_index_file
        SitemapGenerator::Sitemap.create_index = true
        GenerateSitemaps.new.perform

        get '/sitemap.xml.gz'
        assert_equal(200, response.status)

        get '/sitemap1.xml.gz'
        assert_equal(200, response.status)
      end

      def test_sets_the_cache_control_to_1_day
        Workarea.with_config do |config|
          config.strip_http_caching_in_tests = false

          GenerateSitemaps.new.perform
          get '/sitemap.xml.gz'
          assert_equal('public, max-age=86400', response.headers['Cache-Control'])
        end
      end

      def test_viewing_robots_txt
        GenerateSitemaps.new.perform
        get storefront.robots_txt_path
        assert_includes(response.body, Workarea.config.host)
        assert_includes(response.body, 'sitemap.xml.gz')
      end
    end
  end
end
