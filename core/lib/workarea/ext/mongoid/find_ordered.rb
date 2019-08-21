module Mongoid
  class Criteria
    def find_ordered(*ids)
      ids = Array(ids).flatten
      return [] if ids.blank?

      unsorted = any_in(id: ids).to_a
      ids.map { |id| unsorted.detect { |p| p.id.to_s == id.to_s } }.compact
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
