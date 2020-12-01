require 'test_helper'

module Workarea
  class Release
    class ChangesetTest < TestCase
      def test_summary
        release = create_release
        product_one = create_product(id: 'PROD1')
        product_two = create_product(id: 'PROD2')
        page = create_page

        release.as_current do
          product_one.variants.first.update!(details: { 'Color' => 'Orange' })
          product_two.update!(name: 'Test Product Changed')
          page.update!(name: 'Test Page Changed')
        end

        summary = Changeset.summary(release.id)
        assert_includes(summary, { '_id' => 'Workarea::Catalog::Product', 'count' => 2 })
        assert_includes(summary, { '_id' => 'Workarea::Content::Page', 'count' => 1 })
      end

      def test_build_undo
        releasable = create_page(name: 'Foo')
        release = create_release
        release.as_current { releasable.update_attributes!(name: 'Bar') }
        changeset = release.changesets.first

        undo = changeset.build_undo(release: create_release)
        assert_equal(releasable, undo.releasable)
        assert_equal(changeset.document_path, undo.document_path)
        assert_match(/Foo/, undo.changeset.to_s)
        assert_equal('Foo', releasable.name)

        other_release = create_release
        other_release.as_current { releasable.update_attributes!(name: 'Baz') }

        other_release.as_current do
          undo = changeset.build_undo(release: create_release)
          assert_equal(releasable, undo.releasable)
          assert_equal(changeset.document_path, undo.document_path)
          assert_match(/Foo/, undo.changeset.to_s)
          assert_equal('Foo', releasable.name)
        end

        other_release.update_attributes!(publish_at: 1.day.from_now)
        release.update_attributes!(publish_at: 2.days.from_now)
        changeset.reload

        undo = changeset.build_undo(release: create_release)
        assert_equal(releasable, undo.releasable)
        assert_equal(changeset.document_path, undo.document_path)
        assert_match(/Baz/, undo.changeset.to_s)
        assert_equal('Foo', releasable.name)
      end
    end
  end
end
