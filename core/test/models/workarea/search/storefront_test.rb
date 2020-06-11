require 'test_helper'

module Workarea
  module Search
    class StorefrontTest < TestCase
      def test_active
        model = create_product(active: false)
        refute(Storefront.new(model).active[:now])

        model.update!(active: true)
        assert(Storefront.new(model).active[:now])
      end

      def test_changesets
        category = create_category(
          name: 'Foo',
          product_rules: [{ name: 'search', operator: 'equals', value: 'foo' }]
        )
        assert_empty(Storefront.new(category).changesets)

        release = create_release
        release.as_current { category.update!(name: 'Bar') }
        assert_equal(1, Storefront.new(category).changesets.size)

        release.as_current { category.product_rules.first.update!(value: 'bar') }
        assert_equal(2, Storefront.new(category).changesets.size)
      end

      def test_releases
        category = create_category(name: 'Foo')
        assert_empty(Storefront.new(category).as_document[:changeset_release_ids])

        a = create_release(publish_at: 1.week.from_now)
        a.as_current { category.update!(name: 'Bar') }
        assert_equal([a.id], Storefront.new(category).as_document[:changeset_release_ids])

        b = create_release(publish_at: 2.weeks.from_now)
        assert_includes(Storefront.new(category).as_document[:changeset_release_ids], a.id)
        assert_includes(Storefront.new(category).as_document[:changeset_release_ids], b.id)
      end
    end
  end
end
