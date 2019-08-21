require 'test_helper'

module Mongoid
  class FindOrderedTest < Workarea::TestCase
    class FooModel
      include Mongoid::Document
    end

    def test_find_ordered
      models = [FooModel.create!, FooModel.create!, FooModel.create!]
      results = FooModel.find_ordered(models.map(&:id).reverse)
      assert_equal(models.reverse, results)
      results = FooModel.find_ordered(models.map(&:id).map(&:to_s).reverse)
      assert_equal(models.reverse, results)
    end
  end
end
