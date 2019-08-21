module Mongoid
  class LookupHash
    delegate_missing_to :@table

    def initialize(klass)
      @klass = klass
      @table = {}
    end

    def [](value)
      @table[value] || @table[@klass.fields['_id'].type.mongoize(value)]
    end
  end

  class Criteria
    def to_lookup_hash
      scoped.each_with_object(LookupHash.new(klass)) do |model, result|
        result[model.id] = model
      end
    end

    alias_method :to_lookup_h, :to_lookup_hash
  end

  module Document
    class_methods do
      delegate :to_lookup_h, :to_lookup_hash, to: :criteria
    end
  end
end
