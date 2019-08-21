require 'test_helper'

module Mongoid
  class LookupHashTest < Workarea::TestCase
    class BsonIdModel
      include Mongoid::Document
    end

    class IntegerModel
      include Mongoid::Document
      field :_id, type: Integer
    end

    class StringModel
      include Mongoid::Document
      field :_id, type: Integer
    end

    class StringIdModel
      include Mongoid::Document
      field :_id, type: Workarea::StringId
    end

    def test_bson_ids
      one = BsonIdModel.create!
      two = BsonIdModel.create!

      results = BsonIdModel.to_lookup_hash
      assert_equal(2, results.size)
      assert_equal(results[one.id], one)
      assert_equal(results[two.id], two)

      results = BsonIdModel.where(id: one.id).to_lookup_hash
      assert_equal(1, results.size)
      assert_equal(results[one.id], one)
      assert_equal(results[one.id.to_s], one)
    end

    def test_integers
      one = IntegerModel.create!(id: 1)
      two = IntegerModel.create!(id: 2)

      results = IntegerModel.to_lookup_hash
      assert_equal(2, results.size)
      assert_equal(results[1], one)
      assert_equal(results[2], two)

      results = IntegerModel.where(:id.gt => 1).to_lookup_hash
      assert_equal(1, results.size)
      assert_equal(results[2], two)

      results = IntegerModel.where(id: 1).to_lookup_hash
      assert_equal(1, results.size)
      assert_equal(results[1], one)
      assert_equal(results['1'], one)
    end

    def test_strings
      one = StringModel.create!(id: '1')
      two = StringModel.create!(id: '2')

      results = StringModel.to_lookup_hash
      assert_equal(2, results.size)
      assert_equal(results['1'], one)
      assert_equal(results['2'], two)

      results = StringModel.where(id: '1').to_lookup_hash
      assert_equal(1, results.size)
      assert_equal(results['1'], one)
    end

    def test_string_ids
      one = StringIdModel.create!(id: '1')
      two = StringIdModel.create!(id: '2')

      results = StringIdModel.to_lookup_hash
      assert_equal(2, results.size)
      assert_equal(results['1'], one)
      assert_equal(results['2'], two)

      results = StringIdModel.where(id: '1').to_lookup_hash
      assert_equal(1, results.size)
      assert_equal(results['1'], one)
    end
  end
end
