module Workarea
  module Elasticsearch
    module Serializer
      class << self
        def serialize(model)
          serialized = if model.is_a?(Mongoid::Document)
                         serialize_mongoid(model)
                       else
                         serialize_object(model)
                       end

          { 'model_class' => model.class.name, 'model' => serialized }
        end

        def deserialize(source)
          klass = source['model_class'].constantize

          if klass < Mongoid::Document
            deserialize_mongoid(klass, source['model'])
          else
            deserialize_object(source['model'])
          end
        end

        def serialize_mongoid(model)
          serialize_object(model.as_document)
        end

        def serialize_object(object)
          Base64.encode64(Marshal.dump(object))
        end

        def deserialize_mongoid(klass, serialized)
          Mongoid::Factory.from_db(klass, deserialize_object(serialized))
        end

        def deserialize_object(object)
          Marshal.load(Base64.decode64(object))
        end
      end
    end
  end
end
