require 'test_helper'

module Workarea
  module Search
    class FilterTest < TestCase

      setup :set_search

      def set_search
        @search = stub_everything
        @search.stubs(
          params: { 'color' => %w(red), 'foo' => 'bar' }
        )
      end

      def test_current_value
        filter = TermFilter.new(@search, 'foo')
        assert_equal(filter.current_value, 'bar')
      end

      def test_useless
        filter = TermFilter.new(@search, 'foo')
        refute(filter.useless?)

        filter = TermFilter.new(@search, 'baz')
        assert(filter.useless?)
      end

      def test_selected
        filter = TermFilter.new(@search, 'foo')
        assert(filter.selected?('bar'))
        refute(filter.selected?('baz'))

        filter = TermFilter.new(@search, 'baz')
        refute(filter.selected?('foo'))
      end

      def test_system_name
        filter = TermFilter.new(@search, 'foo')
        assert_equal('foo', filter.system_name)

        filter = TermFilter.new(@search, 'Foo BAR')
        assert_equal('foo_bar', filter.system_name)
      end

      def test_display_name
        filter = TermFilter.new(@search, 'foo')
        assert_equal('Foo', filter.display_name)

        filter = TermFilter.new(@search, 'fOO')
        assert_equal('Foo', filter.display_name)
      end

      def test_params_for
        facet = TermsFacet.new(@search, 'color')
        filter = TermFilter.new(@search, 'foo')

        @search.stubs(
          facets: [facet],
          filters: [filter]
        )

        assert_equal({ 'color' => %w(red) }, filter.params_for('bar'))
        assert_equal({ 'color' => %w(red), 'foo' => 'baz' }, filter.params_for('baz'))
      end
    end
  end
end
