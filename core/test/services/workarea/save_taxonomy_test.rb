require 'test_helper'

module Workarea
  class SaveTaxonomyTest < TestCase
    def test_build
      navigable = create_page
      result = SaveTaxonomy.build(navigable)

      assert_equal(navigable.class.name, result.navigable_type)
      assert_equal(navigable.id, result.navigable_id)
    end

    def test_moving
      parent = create_taxon(name: 'Baz')
      create_taxon(parent: parent, position: 0)
      create_taxon(parent: parent, position: 1)

      taxon = Navigation::Taxon.new(navigable: create_page(name: 'Foo'))

      save = SaveTaxonomy.new(
        taxon,
        parent_id: parent.id,
        position: 1
      )

      assert(save.perform)
      taxon.reload

      assert_equal(1, taxon.position)
      assert_equal(parent.id, taxon.parent_id)
      assert_equal('baz-foo', taxon.navigable_slug)

      taxon = Navigation::Taxon.new(navigable: create_page(name: 'Bar', slug: 'the-bar'))

      SaveTaxonomy.new(taxon, parent_id: parent.id, position: nil).perform

      taxon.reload
      assert_equal(3, taxon.position)
      assert_equal('baz-bar', taxon.navigable_slug)
    end

    def test_set_taxonomy_slug
      page = create_page(name: 'Foo Bar')

      parent = create_taxon(name: 'Baz')
      taxon = Navigation::Taxon.new(navigable: page)

      save = SaveTaxonomy.new(taxon, parent_id: parent.id)
      save.perform

      page.reload
      assert_equal('baz-foo-bar', page.slug)
      assert_equal(0, Navigation::Redirect.count)
    end

    def test_set_taxonomy_slug_in_release
      page = create_page(name: 'Foo Bar')
      release = create_release
      parent = create_taxon(name: 'Baz')
      taxon = Navigation::Taxon.new(navigable: page)

      release.as_current do
        save = SaveTaxonomy.new(taxon, parent_id: parent.id)
        save.perform
        page.reload
      end

      assert_equal('baz-foo-bar', page.slug)
      assert_equal(0, Navigation::Redirect.count)
    end
  end
end
