require 'test_helper'

module Workarea
  module Search
    class ProductEntriesTest < TestCase
      def test_entries
        products = Array.new(3) { create_product }

        assert_equal(1, ProductEntries.new(products.first).entries.size)
        assert_equal(3, ProductEntries.new(products).entries.size)
      end

      def test_live_entries
        product = create_product(name: 'Foo')
        create_release.as_current do
          product.update!(name: 'Bar')
          product.reload
        end
        assert_equal('Bar', product.name)

        results = ProductEntries.new(product).live_entries
        assert_equal(1, results.size)
        assert_equal('Foo', results.first.model.name)
        refute_equal(product.object_id, results.first.model.object_id)
      end

      def test_release_entries
        product = create_product(name: 'Foo')
        release = create_release
        release.as_current { product.update!(name: 'Bar') }
        assert_equal('Foo', product.name)

        results = ProductEntries.new(product).release_entries
        assert_equal(1, results.size)
        assert_equal('Bar', results.first.model.name)
        assert_equal(release.id, results.first.release_id)
        refute_equal(product.object_id, results.first.model.object_id)
      end

      def test_entry_flattening
        products = Array.new(2) { create_product }
        release = create_release
        release.as_current { products.first.update!(name: 'Bar') }

        instance = ProductEntries.new(products)
        instance.stubs(:index_entries_for).returns([:foo, :bar])

        assert_equal([:foo, :bar, :foo, :bar, :foo, :bar], instance.entries)
      end
    end
  end
end
