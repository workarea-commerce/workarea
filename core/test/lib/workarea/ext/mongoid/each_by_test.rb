require 'test_helper'

module Mongoid
  class EachByTest < Workarea::TestCase
    class FooModel
      include Mongoid::Document
      field :name, type: Integer
    end

    def test_each_slice_of
      10.times { |i| FooModel.create!(name: i) }

      i = 0
      results = []

      FooModel.desc(:name).each_slice_of(2) do |models|
        i += 1
        results.push(*models)
      end

      assert_equal(5, i)
      assert_equal([9, 8, 7, 6, 5, 4, 3, 2, 1, 0], results.map(&:name))


      i = 0
      results = []

      FooModel.asc(:name).limit(7).each_slice_of(2) do |models|
        i += 1
        results.push(*models)
      end

      assert_equal(4, i)
      assert_equal([0, 1, 2, 3, 4, 5, 6], results.map(&:name))


      i = 0
      results = []

      FooModel.asc(:name).each_slice_of(100) do |models|
        i += 1
        results.push(*models)
      end

      assert_equal(1, i)
      assert_equal([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], results.map(&:name))
    end
  end
end
