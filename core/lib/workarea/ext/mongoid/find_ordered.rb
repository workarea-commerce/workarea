module Mongoid
  class Criteria
    def find_ordered(*ids)
      ids = Array(ids).flatten
      return [] if ids.blank?

      lookup = scoped.any_in(id: ids).to_lookup_hash
      ids.map { |id| lookup[id] }.compact
    end
  end
end

module Mongoid
  module FindOrdered
    def find_ordered(*args)
      criteria.find_ordered(*args)
    end
  end
end

Mongoid::Document::ClassMethods.send(:include, Mongoid::FindOrdered)
