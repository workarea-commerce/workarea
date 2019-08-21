require 'test_helper'

module Workarea
  class GlobalIDTest < TestCase
    class TestModel
      include Mongoid::Document
      include GlobalID::Identification
    end

    def test_mongoization
      global_id = TestModel.create!.to_global_id
      assert_equal(global_id, GlobalID.demongoize(GlobalID.mongoize(global_id)))
      assert_equal(global_id, GlobalID.demongoize(GlobalID.mongoize(global_id.to_s)))
    end
  end
end
