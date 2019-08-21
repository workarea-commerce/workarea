module Workarea
  module Catalog
    class CleanDetails
      def initialize(dirty)
        @dirty = dirty
      end

      def cleaned
        tuples = @dirty.map do |key, value|
          next if key.blank? || value.blank?
          [key, Array.wrap(value)]
        end

        Hash[tuples.compact]
      end
    end
  end
end
