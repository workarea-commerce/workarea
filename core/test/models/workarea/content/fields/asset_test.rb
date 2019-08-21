require 'test_helper'

module Workarea
  class Content
    module Fields
      class AssetTest < TestCase
        def test_typecasting
          asset = Asset.new('foo')
          id = BSON::ObjectId.new

          assert_equal(id.to_s, asset.typecast(id))
          assert_equal(id.to_s, asset.typecast(id.to_s))
        end
      end
    end
  end
end
