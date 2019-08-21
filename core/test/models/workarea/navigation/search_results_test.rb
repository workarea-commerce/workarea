require 'test_helper'

module Workarea
  module Navigation
    class SearchResultsTest < TestCase
      def test_gid_finding
        one = SearchResults.new(q: 'baz', foo: 'bar')
        two = SearchResults.new(foo: 'bar', q: 'baz')

        assert_equal(one.to_gid.find.params, one.params)
        assert_equal(one.to_gid.find.params, one.params)
        assert_equal(one.to_gid.find, two)
      end

      def test_sanitizing_params
        Workarea.with_config do |config|
          config.exclude_from_search_results_breadcrumbs = %i(foo)
          results = SearchResults.new(q: 'baz', foo: 'bar')
          assert_equal({ q: 'baz' }.with_indifferent_access, results.params)
        end
      end

      def test_taxon_construction
        results = SearchResults.new(q: 'baz', foo: 'bar')
        assert_equal(Taxon.root, results.taxon.parent)
        assert_equal(Taxon.root.id, results.taxon.parent_id)
        assert_equal(results, results.taxon.navigable)
        assert(results.taxon.name.include?('baz'))
      end
    end
  end
end
