require 'test_helper'

module Mongoid
  class QueryCacheTest < Workarea::TestCase
    class FooModel
      include Mongoid::Document
      field :name
    end

    def test_cached_data_changes
      id = FooModel.create!(name: 'Foo').id

      Mongoid::QueryCache.cache do
        instance = FooModel.find(id)
        assert_equal('Foo', instance.name)

        instance.name = 'Bar'
        assert_equal('Foo', FooModel.find(instance.id).name)
      end
    end
  end
end
