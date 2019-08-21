require 'test_helper'

module Workarea
  module Search
    class FacetTest < TestCase
      class TestFacet < Facet
        attr_accessor :results, :params, :total

        def initialize(*)
          super
          @params = {}
          @results = {}
          @total = 0
        end

        def value_to_param(value)
          value.downcase
        end
      end

      def test_selections
        facet = TestFacet.new(stub_everything, 'foo')

        facet.params = { 'foo' => [''] }
        assert(facet.selections.empty?)

        facet.params = { 'foo' => ['bar'] }
        assert_equal(1, facet.selections.size)
        assert_equal('bar', facet.selections.first)
      end

      def test_useless
        facet = TestFacet.new(stub_everything, 'color')

        facet.total = 4
        facet.results = { 'Red' => 4 }
        facet.params = {}
        assert(facet.useless?)

        facet.total = 5
        facet.results = { 'Red' => 4 }
        facet.params = {}
        refute(facet.useless?)

        facet.total = 4
        facet.results = { 'Red' => 4 }
        facet.params = { 'color' => 'Red' }
        refute(facet.useless?)

        facet.total = 4
        facet.results = { 'Red' => 4, 'Green' => 2 }
        facet.params = {}
        refute(facet.useless?)
      end

      def test_selected
        facet = TestFacet.new(stub_everything, 'color')
        facet.params = {}
        refute(facet.selected?)

        facet.params = { 'color' => '' }
        refute(facet.selected?)

        facet.params = { 'color' => 'red' }
        assert(facet.selected?)
        assert(facet.selected?('red'))
        refute(facet.selected?('blue'))

        facet.params = { 'color' => %w(red blue) }
        assert(facet.selected?)
        assert(facet.selected?('ReD'))
        assert(facet.selected?('Blue'))
      end

      def test_params_for
        search = stub_everything
        facet = TestFacet.new(search, 'color')

        search.stubs(
          facets: [
            facet,
            TestFacet.new(stub_everything, 'size')
          ],
          filters: [
            TermFilter.new(stub_everything, 'foo')
          ]
        )

        facet.params = { 'color' => %w(red blue) }
        assert_equal({ 'color' => %w(blue) }, facet.params_for('red'))
        assert_equal({ 'color' => %w(red) }, facet.params_for('blue'))
        assert_equal({ 'color' => %w(red blue green) }, facet.params_for('green'))

        facet.params = { 'color' => %w(red), 'size' => %w(large) }
        assert_equal({ 'size' => %w(large) }, facet.params_for('red'))

        facet.params = { 'color' => %w(red), 'sort' => 'newest' }
        assert_equal({ 'sort' => 'newest' }, facet.params_for('red'))

        facet.params = { 'color' => %w(red), 'foo' => 'bar' }
        assert_equal({ 'foo' => 'bar' }, facet.params_for('red'))

        facet.params = { 'color' => 'red' }
        assert_equal({ 'color' => %w(red green) }, facet.params_for('green'))
      end
    end
  end
end
