module Workarea
  module Search
    class HashText
      attr_reader :hash

      def initialize(hash)
        @hash = hash || {}
      end

      # Flatten out all values in the hash and
      # returns a comma-delimited string. Used for
      # entering catalog Hash data into the search index
      # for full text searching.
      #
      # @return [String]
      #
      def text
        hash.map do |key, value|
          value_string = if value.is_a?(Hash)
                           HashText.new(value).text
                         elsif value.is_a?(Array)
                           value.join(', ')
                         else
                           value
                         end

          "#{key.to_s.humanize}: #{value_string}"
        end.join('; ')
      end
    end
  end
end
