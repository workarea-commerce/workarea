require 'test_helper'

module Workarea
  module Search
    class FacetSortingTest < TestCase
      class FooOrdering
        def self.call(name, results)
          Hash[results.sort]
        end
      end

      class BadOrderingClass
        # Does not have a call method.
      end

      setup :set_configs
      teardown :reset_configs

      def set_configs
        Workarea.configure do |config|
          @facet_sorting = config.search_facet_sorts
          @default_sorting = config.search_facet_default_sort
          @facet_size = config.search_facet_dynamic_sorting_size

          config.search_facet_sorts = {}
          config.search_facet_default_sort = :count
          config.search_facet_dynamic_sorting_size = 25
        end
      end

      def reset_configs
        Workarea.configure do |config|
          config.search_facet_sorts = @facet_sorting
          config.search_facet_default_sort = @default_sorting
          config.search_facet_dynamic_sorting_size = @facet_size
        end
      end

      def test_to_h
        Workarea.config.search_facet_sorts = { size: :count }
        sorting = FacetSorting.new('size')
        assert_equal({ order: { '_count' => 'desc' } }, sorting.to_h)

        Workarea.config.search_facet_sorts = { size: :alphabetical_asc }
        sorting = FacetSorting.new('size')
        assert_equal({ order: { '_term' => 'asc' } }, sorting.to_h)

        Workarea.config.search_facet_sorts = { size: :alphabetical_desc }
        sorting = FacetSorting.new('size')
        assert_equal({ order: { '_term' => 'desc' } }, sorting.to_h)

        Workarea.config.search_facet_sorts = { size: Proc.new {} }
        sorting = FacetSorting.new('size')
        assert_equal({ size: 25, order: { '_count' => 'desc' } }, sorting.to_h)

        Workarea.config.search_facet_sorts = { size: FooOrdering.name }
        sorting = FacetSorting.new('size')
        assert_equal({ size: 25, order: { '_count' => 'desc' } }, sorting.to_h)

        Workarea.config.search_facet_sorts = { size: BadOrderingClass.name }
        sorting = FacetSorting.new('size')
        assert_equal({}, sorting.to_h)

        Workarea.config.search_facet_sorts = { size: 'NotAClassOrOption' }
        sorting = FacetSorting.new('size')
        assert_equal({}, sorting.to_h)
      end

      def test_apply
        results = { 'Red' => 20, 'Blue' => 15, 'Green' => 10, 'Yellow' => 5 }

        Workarea.config.search_facet_sorts = { size: :count }
        sorting = FacetSorting.new('size')
        assert_equal(results, sorting.apply(results))
        assert_equal(results, sorting.apply(results, 2))

        Workarea.config.search_facet_sorts = { size: BadOrderingClass.name }
        sorting = FacetSorting.new('size')
        assert_equal(results, sorting.apply(results))

        Workarea.config.search_facet_sorts = { size: 'NotAClassOrOption' }
        sorting = FacetSorting.new('size')
        assert_equal(results, sorting.apply(results))

        Workarea.config.search_facet_sorts = { size: FooOrdering.name }
        sorting = FacetSorting.new('size')
        assert_equal(Hash[results.sort], sorting.apply(results))
        assert_equal(Hash[results.sort.first(3)], sorting.apply(results, 3))

        Workarea.config.search_facet_sorts = {
          size: -> (name, results) { Hash[results.sort.reverse] }
        }
        sorting = FacetSorting.new('size')
        assert_equal(Hash[results.sort.reverse], sorting.apply(results))
        assert_equal(Hash[results.sort.reverse.first(3)], sorting.apply(results, 3))
      end

      def test_dynamic_option
        Workarea.config.search_facet_sorts = { size: :count }
        sorting = FacetSorting.new('size')
        assert_nil(sorting.dynamic_option)
        refute(sorting.dynamic?)

        Workarea.config.search_facet_sorts = { size: FooOrdering.name }
        sorting = FacetSorting.new('size')
        assert_equal(FooOrdering, sorting.dynamic_option)
        assert(sorting.dynamic?)

        size_proc = Proc.new {}
        Workarea.config.search_facet_sorts = { size: size_proc }
        sorting = FacetSorting.new('size')
        assert_equal(size_proc, sorting.dynamic_option)
        assert(sorting.dynamic?)

        Workarea.config.search_facet_sorts = { size: 'NotAClassOrOption' }
        sorting = FacetSorting.new('size')
        assert_nil(sorting.dynamic_option)
        refute(sorting.dynamic?)

        Workarea.config.search_facet_sorts = { size: BadOrderingClass.name }
        sorting = FacetSorting.new('size')
        assert_nil(sorting.dynamic_option)
        refute(sorting.dynamic?)
      end
    end
  end
end
