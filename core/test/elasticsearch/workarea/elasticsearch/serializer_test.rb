require 'test_helper'

module Workarea
  module Elasticsearch
    class SerializerTest < TestCase
      def test_deserialize_mongoid_uses_instantiate
        model = Catalog::Product.new(name: 'Test')
        attributes = model.as_document
        source = Serializer.serialize(model)

        if defined?(Mongoid::Factory) && Mongoid::Factory.respond_to?(:from_db)
          Mongoid::Factory.stubs(:from_db).raises('Mongoid::Factory.from_db should not be called')
        end

        Catalog::Product
          .expects(:instantiate)
          .with(attributes)
          .once
          .returns(model)

        assert_equal(model, Serializer.deserialize(source))
      end
    end
  end
end
