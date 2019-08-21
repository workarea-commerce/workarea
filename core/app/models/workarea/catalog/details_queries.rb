module Workarea
  module Catalog
    class DetailsQueries
      # Find distinct detail values for the given field name that match the given search string.
      #
      # @param name [String]
      # @param query [String]
      #
      # @return [Array<String>]
      #
      def self.find_details(name, query)
        find_distinct("details.#{I18n.locale}.#{name}", query)
      end

      # Find distinct filter values for the given field name that match the given search string.
      #
      # @param name [String]
      # @param query [String]
      #
      # @return [Array<String>]
      #
      def self.find_filters(name, query)
        find_distinct("filters.#{I18n.locale}.#{name}", query)
      end

      # Find distinct variant detail values for the given field name that match the given search string.
      #
      # @param name [String]
      # @param query [String]
      #
      # @return [Array<String>]
      #
      def self.find_sku_details(name, query)
        find_distinct("variants.details.#{I18n.locale}.#{name}", query)
      end

      # Find distinct image option values that match the given search string.
      #
      # @param name [String]
      # @param query [String]
      #
      # @return [Array<String>]
      #
      def self.find_image_options(query)
        find_distinct('images.option', query)
      end

      private

      def self.find_distinct(item, query)
        Product.all.distinct(item).select do |value|
          value =~ /^#{::Regexp.quote(query.to_s)}/i
        end
      end
    end
  end
end
