module Workarea
  module Search
    # This class represents a range filter coming in from a query string.
    # It parses this query string into a usable data structure.
    #
    class RangeParameter
      attr_reader :string

      # Take any range facet value and convert it to its param representation.
      #
      # @param [Object]
      # @return [String]
      #
      def self.to_param(value)
        if value.respond_to?(:to_h)
          value = value.to_h.with_indifferent_access
          "#{value[:from].presence || '*'}-#{value[:to].presence || '*'}"
        else
          value.to_s
        end
      end

      def initialize(string)
        @string = string.to_s
      end

      # The beginning of the range.
      #
      # @return [String]
      #
      def start
        to_a[0].present? ? clean(to_a[0]) : ''
      end

      # The end of the range.
      #
      # @return [String]
      #
      def stop
        to_a[1].present? ? clean(to_a[1]) : ''
      end

      # An array form of the filter with start as the first
      # element and stop as the second.
      #
      # @return [Array]
      #
      def to_a
        @array ||= string.blank? ? [] : string.split('-')
      end

      # Returns a hash form of the filter, usable
      # in Elasticsearch query-building.
      #
      # @return [Hash]
      #
      def to_filter
        result = {}
        result[:gte] = start if start.present? && start != '*'
        result[:lt] = stop if stop.present? && stop != '*'
        result
      end

      private

      def clean(string)
        string.gsub(/['"]/, '')
      end
    end
  end
end
