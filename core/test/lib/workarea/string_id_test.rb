require 'test_helper'

module Workarea
  class StringIdTest < TestCase
    class FooModel
      include Mongoid::Document
      field :_id, type: StringId, default: -> { BSON::ObjectId.new }
    end

    def test_querying_on_id
      model = FooModel.create!
      assert(model.id.is_a?(BSON::ObjectId))
      assert_equal(model, FooModel.find(model.id))

      found = FooModel.find(model.id.to_s)
      assert_equal(model, found)
      assert(found.id.is_a?(BSON::ObjectId))

      model = FooModel.create!(id: '5b900d884907b7417f9c33d5')
      assert(model.id.is_a?(BSON::ObjectId))

      found = FooModel.find('5b900d884907b7417f9c33d5')
      assert(found.id.is_a?(BSON::ObjectId))
      assert_equal(model, found)

      found = FooModel.find(BSON::ObjectId.from_string('5b900d884907b7417f9c33d5'))
      assert(found.id.is_a?(BSON::ObjectId))
      assert_equal(model, found)

      string_model = FooModel.create!(id: 'foobar')
      assert(string_model.id.is_a?(String))

      found = FooModel.find('foobar')
      assert(found.id.is_a?(String))
      assert_equal(string_model, found)

      mixed = FooModel.in(id: ['foobar', '5b900d884907b7417f9c33d5']).to_a
      assert_equal(2, mixed.count)
      assert(mixed.include?(model))
      assert(mixed.include?(string_model))
    end
  end
end
