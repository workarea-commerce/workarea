module Workarea
  module Search
    class FacetValues
      # Clean up values to remove blanks, duplicates,
      # and extra whitespace. Also converts all values to be strings.
      # Used when adding product facet values into the Elasticsearch
      # index.
      #
      # @return [Array<String>]
      #
      def self.sanitize(values)
        Array(values).flatten.map(&:to_s).reject(&:blank?).map(&:strip).uniq
      end
    end
  end
end
