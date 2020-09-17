require 'test_helper'

module Workarea
  class GenerateSitemapsTest < Workarea::TestCase
    def test_does_not_add_mailto_link_to_sitemap
      url = 'mailto:noreply@example.com'
      create_taxon(url: url)
      GenerateSitemaps.new.perform
      contents = Zlib::GzipReader.new(Sitemap.first.file.file).read

      refute_includes(contents, url)
    end

    def test_adds_product_to_sitemap
      product = create_product(slug: 'test-product')
      GenerateSitemaps.new.perform

      contents = Zlib::GzipReader.new(Sitemap.first.file.file).read
      assert_includes(contents, "https://#{Workarea.config.host}/products/test-product")

      product.variants.destroy_all
      GenerateSitemaps.new.perform
      contents = Zlib::GzipReader.new(Sitemap.first.file.file).read

      refute_includes(contents, "https://#{Workarea.config.host}/products/test-product")
    end

    def test_adds_navigation_link_with_url
      parent = create_taxon
      url = 'https://alt.example.com/hello'
      create_taxon(url: url, parent: parent)
      GenerateSitemaps.new.perform

      contents = Zlib::GzipReader.new(Sitemap.first.file.file).read
      assert_includes(contents, url)
    end

    def test_adds_navigation_link_with_relative_path
      parent = create_taxon
      url = '/hello'
      create_taxon(url: url, parent: parent)
      GenerateSitemaps.new.perform

      contents = Zlib::GzipReader.new(Sitemap.first.file.file).read
      assert_includes(contents, "http://#{Workarea.config.host}" + url)
      refute_includes(contents, '<loc>://')
    end

    def test_adds_navigation_link_with_navigable
      create_taxon(
        navigable: create_page(slug: 'test-page'),
        parent: create_taxon
      )

      GenerateSitemaps.new.perform

      contents = Zlib::GzipReader.new(Sitemap.first.file.file).read
      assert_includes(contents, 'test-page')
    end

    def test_does_not_add_link_for_inactive_taxon
      create_taxon(navigable: create_page(slug: 'foo', active: false))
      GenerateSitemaps.new.perform

      contents = Zlib::GzipReader.new(Sitemap.first.file.file).read
      refute_includes(contents, 'foo')
    end

    def test_cleans_up_tmp_directory
      GenerateSitemaps.new.perform
      refute(Dir.exists?(Rails.root.join('tmp', 'sitemaps')))
    end

    def test_overwrites_existing_sitemap
      GenerateSitemaps.new.perform
      GenerateSitemaps.new.perform

      assert_equal(1, Sitemap.count)
    end
  end
end
