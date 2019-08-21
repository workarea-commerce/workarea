require 'test_helper'

module Mongoid
  class ExceptTest < Workarea::TestCase
    class ExceptDoc
      include Mongoid::Document
    end

    def test_returns_docs_except_the_passed_id
      one = ExceptDoc.create!
      two = ExceptDoc.create!

      results = ExceptDoc.all.except(two.id).to_a
      assert_equal(1, results.length)
      assert_equal(one.id, results.first.id)
    end
  end
end
