require 'test_helper'

module Workarea
  class FeaturedProductsChangesetsTest < TestCase
    def test_changesets_finds_by_product_id_in_changeset_and_original
      release = create_release

      in_changeset = Release::Changeset.create!(
        release:    release,
        changeset:  { 'product_ids' => %w(P1 P2) },
        original:   {}
      )

      in_original = Release::Changeset.create!(
        release:    release,
        changeset:  {},
        original:   { 'product_ids' => %w(P1) }
      )

      unrelated = Release::Changeset.create!(
        release:    release,
        changeset:  { 'product_ids' => %w(P3) },
        original:   { 'product_ids' => %w(P4) }
      )

      results = FeaturedProducts.changesets('P1').to_a
      assert_includes(results, in_changeset)
      assert_includes(results, in_original)
      refute_includes(results, unrelated)
    end
  end
end
