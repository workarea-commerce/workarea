require 'test_helper'

module Workarea
  class FindTaxonomySlugTest < TestCase
    def test_slug
      parent_taxon = create_taxon(name: 'Baz')

      navigable = create_category(name: 'Foo Bar')
      create_taxon(navigable: navigable, parent: parent_taxon)

      slug = FindTaxonomySlug.new(navigable).slug
      assert_equal('baz-foo-bar', slug)

      navigable.update_attributes!(slug: slug)
      navigable_two = create_category(name: 'Foo Bar')
      create_taxon(navigable: navigable_two, parent: parent_taxon)
      assert_equal('baz-foo-bar-1', FindTaxonomySlug.new(navigable_two).slug)
    end
  end
end
