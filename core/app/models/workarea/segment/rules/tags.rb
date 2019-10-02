module Workarea
  class Segment
    module Rules
      class Tags < Base
        include Mongoid::Document::Taggable

        def qualifies?(visit)
          return false if tags.blank? || visit.metrics.tags.blank?
          (tags & visit.metrics.tags).any?
        end
      end
    end
  end
end
