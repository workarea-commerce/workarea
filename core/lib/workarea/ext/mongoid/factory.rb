module Mongoid
  module Factory
    module FixQueryCache
      def from_db(klass, attributes = nil, selected_fields = nil)
        attributes = attributes.deep_dup if QueryCache.enabled? && attributes.present?
        super(klass, attributes, selected_fields)
      end
    end

    extend FixQueryCache
  end
end
