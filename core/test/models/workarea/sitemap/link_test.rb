require 'test_helper'

module Workarea
  class Sitemap
    class LinkTest < TestCase
      def test_host
        page = create_page
        navigable = Link.new(
          taxon: create_taxon(navigable: page),
          generator: GenerateSitemaps.new
        )
        external_https = Link.new(
          taxon: create_taxon(url: 'https://alt.example.com/foo/bar'),
          generator: GenerateSitemaps.new
        )
        external_http = Link.new(
          taxon: create_taxon(url: 'http://alt.example.com/foo/bar'),
          generator: GenerateSitemaps.new
        )
        external_path = Link.new(
          taxon: create_taxon(url: '/foo/bar'),
          generator: GenerateSitemaps.new
        )


        assert_equal('https://alt.example.com', external_https.host)
        assert_equal('http://alt.example.com', external_http.host)
        assert_equal("http://#{Workarea.config.host}", navigable.host)
        assert_equal("http://#{Workarea.config.host}", external_path.host)
        Rails.configuration.force_ssl = true
        assert_equal("https://#{Workarea.config.host}", navigable.host)
        assert_equal("https://#{Workarea.config.host}", external_path.host)
      ensure
        Rails.configuration.force_ssl = false
      end

      def test_path
        page = create_page
        navigable = Link.new(
          taxon: create_taxon(navigable: page),
          generator: GenerateSitemaps.new
        )
        external_url = Link.new(
          taxon: create_taxon(url: 'https://alt.example.com/foo/bar'),
          generator: GenerateSitemaps.new
        )
        external_path = Link.new(
          taxon: create_taxon(url: '/foo/bar'),
          generator: GenerateSitemaps.new
        )

        assert_equal('/foo/bar', external_url.path)
        assert_equal('/foo/bar', external_path.path)
        assert_equal("/pages/#{page.slug}", navigable.path)
      end
    end
  end
end
