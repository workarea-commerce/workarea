require 'test_helper'

module Workarea
  class TaxonomySitemapTest < TestCase
    setup :create_taxonomy

    def create_taxonomy
      @landing = create_taxon(name: 'Landing', url: '/')
      @placeholder = create_taxon(name: 'Placeholder')

      create_taxon(name: 'Page Active', parent: @landing, navigable: create_page)
      create_taxon(name: 'Page Inactive', parent: @landing, navigable: create_page(active: false))
      create_taxon(name: 'Category Active', parent: @placeholder, navigable: create_category)
      create_taxon(name: 'Category Inactive', parent: @placeholder, navigable: create_category(active: false))
      create_taxon(name: 'Link to Nowhere', url: 'foobar')
    end

    def test_taxons
      sitemap = TaxonomySitemap.new
      assert_equal(7, sitemap.taxons.length)
      refute_includes(sitemap.taxons, @placeholder)
    end

    def test_results
      sitemap = TaxonomySitemap.new
      assert_equal(4, sitemap.results.length)

      names = sitemap.results.map(&:name)
      assert_includes(names, 'Home')
      assert_includes(names, 'Landing')
      assert_includes(names, 'Category Active')
      assert_includes(names, 'Page Active')
    end
  end
end
