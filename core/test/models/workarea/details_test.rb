require 'test_helper'

module Workarea
  class DetailsTest < Workarea::TestCase
    class Foo
      include Mongoid::Document
      include Details
    end

    def test_cleans_details
      model = Foo.new
      model.details = { 'foo' => {} }
      model.valid?
      assert_equal(model.details, {})

      model.details = { 'foo' => 'bar' }
      model.valid?
      assert_equal(model.details['foo'], ['bar'])
    end

    def test_update_details_merges_values
      model = Foo.new(details: { 'foo' => 'bar' })
      model.update_details('foo' => 'baz')

      assert_equal(model.details['foo'], 'baz')
    end

    def test_update_details_removes_blank_values
      model = Foo.new(details: { 'foo' => 'bar' })
      model.update_details('foo' => '')

      refute(model.details.keys.include?('foo'))
    end

    def test_matches_details_array_values
      model = Foo.new(details: { 'foo' => ['BaR  '] })
      assert(model.matches_detail?('foo', ' BAr'))
    end

    def test_matches_details_values
      model = Foo.new(details: { 'foo' => 'BaR  ' })
      assert(model.matches_detail?('foo', ' BAr'))
    end

    def test_matches_details_array_arguments
      model = Foo.new(details: { 'foo' => ['BaR  '] })
      assert(model.matches_details?('foo' => [' BAr']))

      model = Foo.new(details: { 'foo' => 'BaR  ' })
      assert(model.matches_details?('foo' => [' BAr']))
    end

    def test_detail_names
      default_model = Foo.new(details: { 'foo' => 'bar' })
      rehydrated_model = Foo.new(details: {
        I18n.locale.to_s => { 'foo' => 'bar' }
      })

      assert_includes(default_model.detail_names, 'foo')
      assert_includes(rehydrated_model.detail_names, 'foo')
    end
  end
end
